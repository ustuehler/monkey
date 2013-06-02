require 'monkey/accounting'

module Monkey::Accounting

  # Human-readable accounting ledger (http://ledger-cli.org)
  class Ledger

    DATE = /\d{4}\/\d{2}\/\d{2}/
    WORD = /(?:[^ ]|.[^ ])+/

    attr_accessor :entries
    attr_accessor :filename

    # Loads a ledger file and remembers the file name.
    #
    # @param [String] filename  The file to load the ledger from.
    #  It is saved in the +filename+ attribute for use by {#save!}.
    def self.load_file(filename)
      File.open(filename, 'r') do |input|
        ledger = new(input)
        ledger.filename = filename
        ledger
      end
    end

    # Saves the ledger to a file.
    #
    # @param [String,nil] filename  The file to save the ledger to.
    #  When `filename` is nil, the filename attribute is consulted,
    #  which is normally set by the {#load_file} method.
    def save!(filename = nil)
      filename ||= @filename
      raise "no filename to save ledger to" unless filename
      File.open(filename, 'w') { |f| f.write(self.to_s + "\n") }
    end

    # Creates a new ledger from the specified input.
    #
    # @param [String,IO]  The ledger input in human-readable format.
    #   If `input` is not specified, an empty ledger is created.
    def initialize(input = "")
      @entries = []
      parse input
    end

    # Parses the specified input in human-readable form and remembers
    # the parsed entries.
    #
    # @param [String,IO]  The ledger input in human-readable format.
    #  If `input` is not specified, an empty ledger is created.
    # @return [Array]  The entries that were parsed and appended to
    #  the already existing entries.
    def parse(input)
      case input
      when IO
        # canonical form
      when String
        input = StringIO.new(input)
      else
        raise ArgumentError, "invalid input for #{self.class}#parse " +
          "(expected: String or IO object; got: #{input.inspect})"
      end

      lineno = 0
      date, edate, flag, code, desc = nil
      txns = []
      entries = []

      begin
        while line = input.readline
          line.chomp!
          lineno += 1

          case line.chars.first
          when nil
            # Skip empty lines.
            next
          when ';'
            # Skip comments.
            next
          when '0'..'9'
            # NUMBER denotes the beginning of an entry of the form:
            # DATE[=EDATE] [*|!] [(CODE)] DESC
            if line =~ /^(#{DATE})(?:=(#{DATE}))?(?: ([*!]))?(?: \(([^)]+)\))? (.*)$/
              entries << Entry.new(date, edate, flag, code, desc, txns) if date
              date, edate, flag, code, desc = $1, $2, $3, $4, $5
              txns = []
            else
              raise "invalid entry, line #{lineno}: #{line.inspect}"
            end
          when ' '
            # Transactions are denoted by a space at the beginning
            # of the line and must belong to an entry.  Transations
            # are of the form: ACCOUNT[  AMOUNT][  ;NOTE]
            if date and line =~ /^ +(#{WORD})(?:  +(#{WORD}))?(?:  +;(.*)| *)?$/
              account, amount, note = $1, $2, $3
              amount = Amount.parse(amount) unless amount.nil?
              txns << Transaction.new(account, amount, note)
            else
              raise "invalid transaction, line #{lineno}: #{line.inspect}"
            end
          else
            raise "unmatched input, line #{lineno}: #{line.inspect}"
          end
        end
      rescue EOFError
        entries << Entry.new(date, edate, flag, code, desc, txns) if date
      end

      @entries += entries
      entries
    end

    # Returns the earliest entry's date.
    def start_date
      entries.map { |e| Date.parse e.date }.sort.first
    end

    # Returns the latest entry's date.
    def end_date
      entries.map { |e| Date.parse e.date }.sort.last
    end

    # Return the total balance computed over all top-level accounts in
    # this ledger.  This amount should always be zero due to double-entry
    # accounting.
    def balance
      accounts.reject { |a| a.include? ':' }.map { |a| a.balance }.reduce(:+)
    end

    # Deletes matching entries and returns the list of deleted entries.
    # The block is called for each existing entry and the entry is deleted
    # if the block yields a true value.
    def delete_entries!(&block)
      entries.select { |e| yield e }.each { |e|
        entries.delete e
      }
    end

    class Account < String
      def initialize(ledger, name)
        @ledger = ledger
        super(name)
      end

      # Adds a new entry to the ledger.
      #
      # @param [Amount, String] amount  The amount transferred to this
      #  account, which may be negative.
      # @param [Account, String] account  The account against which the
      #  first transaction is balanced.  The negated +amount+ is either
      #  added or subtracted from that account.
      # @param [Array<Amount, Account, String>] args  The first of the
      #  remaining arguments is interpreted as an optional split amount
      #  to balance against +account+ instead of the +amount+ given.  Any
      #  arguments after the first are interpreted as tuples of the form
      #  +[account, split_amount[, account, split_amount, ...]]+ and specify
      #  additional transactions for this entry that move partial amounts
      #  to or from other accounts.
      # @return [Entry]  The entry that was added to the ledger.
      def add_entry(amount, account, *args)
        e = Entry.new(Time.now.strftime '%Y/%m/%d')
        e.transactions = [Transaction.new(self, amount)]
        if args.size == 0
          e.transactions << Transaction.new(account, -amount)
        elsif (args.size % 3) != 0
          raise ArgumentError, "invalid number of arguments: #{args.inspect}"
        else
          split_amount = args.shift
          e.transactions << Transaction.new(account, -split_amount)
          while args.size >= 2
            account, split_amount = args.shift(2)
            e.transactions << Transaction.new(account, -split_amount)
          end
        end
        @ledger.entries << e
        e
      end

      # Returns the total balance for this account.
      def balance
        entries.map { |e|
          e.transactions.select { |t|
            t.account == self or t.account.start_with? "#{self}:"
          }.map { |t|
            if t.amount.nil?
              e.null_amount
            else
              t.amount
            end
          }.reduce(:+) or Amount.zero
        }.reduce(:+) or Amount.zero
      end

      def entries
        @ledger.entries.select { |e|
          e.transactions.any? { |t|
            t.account == self or t.account.start_with? "#{self}:"
          }
        }
      end

      def exists?
        @ledger.accounts.include? self
      end
    end

    def accounts
      entries.map { |e|
        e.transactions.map { |t|
          a = t.account
          alist = []
          while last_separator = a.rindex(':')
            alist << a
            a = a[0...last_separator]
          end
          alist << a
          alist
        }
      }.flatten.uniq.map { |a|
        account a
      }
    end

    def account(name)
      Account.new(self, name)
    end

    def to_s
      entries.map { |e| e.to_s }.join("\n\n")
    end

  end

end

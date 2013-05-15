require 'monkey/accounting'

module Monkey::Accounting

  # Human-readable ledger (http://ledger-cli.org)
  class Ledger

    DATE = /\d{4}\/\d{2}\/\d{2}/
    WORD = /(?:[^ ]|.[^ ])+/

    attr_reader :entries

    def self.load_file(filename)
      File.open(filename, 'r') { |input| new input }
    end

    # Create a new ledger from the specified input.
    #
    # @param [String,IO] The ledger input in human-readable format.
    #   If `input` is not specified, an empty ledger is created.
    def initialize(input = "")
      @entries = []
      parse input
    end

    # Parse the specified input in human-readable form and remember
    # the parsed entries.
    #
    # @param [String,IO] The ledger input in human-readable format.
    #   If `input` is not specified, an empty ledger is created.
    # @return [Array] The entries that were parsed and appended to
    #   the already existing entries.
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
              entries << Entry.new([date, edate, flag, code, desc, txns]) if date
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
              txns << Transaction.new([account, amount, note])
            else
              raise "invalid transaction, line #{lineno}: #{line.inspect}"
            end
          else
            raise "unmatched input, line #{lineno}: #{line.inspect}"
          end
        end
      rescue EOFError
        entries << Entry.new([date, edate, flag, code, desc, txns]) if date
      end

      @entries += entries
      entries
    end

    class Account < String
      def initialize(ledger, name)
        @ledger = ledger
        super(name)
      end

      def entries
        @ledger.entries.select { |e|
          e.transactions.any? { |t|
            t.account == self
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
          t.account
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

    # Helper module to make array fields accessible by name.
    module IndexAccessor
      def index_accessor(name, index)
        define_method(name) do
          self[index]
        end

        define_method("#{name}=") do |value|
          self[index] = value
        end
      end
    end

    # Single ledger entry with two or more transactions.
    class Entry < Array
      extend IndexAccessor

      index_accessor :date, 0
      index_accessor :effective_date, 1
      index_accessor :flag, 2
      index_accessor :code, 3
      index_accessor :description, 4
      index_accessor :transactions, 5

      def to_s
        date + (effective_date ? "=#{effective_date}" : "") +
          (flag ? " #{flag}" : "") +
          (code ? " (#{code})" : "") +
          (description ? " #{description}" : "") +
          (transactions.empty? ? "" :
           "\n" + transactions.map { |t| t.to_s }.join("\n"))
      end
    end

    # Single transaction in a ledger entry.  There must be at least two
    # transactions per entry (double accounting).
    class Transaction < Array
      extend IndexAccessor

      index_accessor :account, 0
      index_accessor :amount, 1
      index_accessor :note, 2

      def to_s
        "  #{account}" +
          (amount ? "  #{amount}" : "") +
          (note ? "  ;#{note}" : "")
      end
    end

  end

end

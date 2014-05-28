require 'monkey/accounting'

module Monkey::Accounting

  # Single ledger entry with two or more transactions.
  class Entry

    attr_reader :date
    attr_reader :effective_date
    attr_accessor :flag
    attr_accessor :code
    attr_accessor :description
    attr_accessor :transactions

    # Sets the entry's date, calling {Date#parse} on +value+ if it is
    # not already a +Date+.
    def date=(value)
      case value
      when Date
        @date = value
      else
        @date = Date.parse(value.to_s)
      end
    end

    # Sets the entry's effective date, calling {Date#parse} on +value+
    # if it is not already a +Date+ or +nil+.
    def effective_date=(value)
      case value
      when Date, NilClass
        @effective_date = value
      else
        @effective_date = Date.parse(value.to_s)
      end
    end

    # A double-accounting +Entry+ is initialized using a date and
    # optional effective date, flag, code, description and initial
    # list of transactions.  All arguments should be +String+s or
    # +nil+ (if they are optional and not given), except for
    # +transactions+, which must be an +Array+.
    def initialize(date, effective_date = nil, flag = nil, code = nil,
      description = nil, transactions = [])

      self.date = date
      self.effective_date = effective_date

      @flag, @code, @description, @transactions =
        flag, code, description, transactions
    end

    # Returns the total balance for this entry, which should
    # normally be zero.
    def balance
      transactions.map { |t|
        if t.amount.nil?
          null_amount
        else
          t.amount
        end
      }.reduce(:+)
    end

    # Returns the sum of all transactions with non-negative amounts in this
    # entry.
    def amount
      transactions.map { |t|
        if t.amount.nil?
          null_amount
        else
          t.amount
        end
      }.select { |amount|
        amount >= 0
      }.reduce(:+)
    end

    # Computes the total amount which was transferred to one of the given
    # accounts (or a subaccount).
    def amount_to(accounts)
      transactions.select { |t|
        accounts.any? { |a| t.account == a or t.account.start_with?("#{a}:") }
      }.map { |t|
        if t.amount.nil?
          null_amount
        else
          t.amount
        end
      }.reduce(:+)
    end

    # If there's a transaction with a "null" amount in this entry,
    # returns the amount of that transaction, which is the amount
    # that would balance the entry.  If there is no transaction
    # with a null amount, returns nil.
    def null_amount
      non_null_total = nil
      null_txn = nil

      transactions.each { |t|
        if t.amount.nil?
          if null_txn.nil?
            null_txn = t
          else
            raise "only one transaction with null amount is allowed"
          end
        else
          if non_null_total.nil?
            non_null_total = t.amount
          else
            non_null_total += t.amount
          end
        end
      }

      -non_null_total
    end

    # Returns the list of all accounts which are referenced in the
    # transactions of this entry.
    def accounts
      transactions.map { |t| t.account }
    end

    DATE_FORMAT = '%Y/%m/%d'

    def to_s
      "#{date.strftime DATE_FORMAT}" +
        (effective_date ? "=#{effective_date.strftime DATE_FORMAT}" : "") +
        (flag ? " #{flag}" : "") +
        (code ? " (#{code})" : "") +
        (description ? " #{description}" : "") +
        (transactions.empty? ? "" :
         "\n" + transactions.map { |t| t.to_s }.join("\n"))
    end

  end

end

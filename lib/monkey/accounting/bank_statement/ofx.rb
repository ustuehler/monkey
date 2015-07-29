require 'monkey/accounting'
require 'monkey/patches/ofx'

module Monkey::Accounting

  # Parser for a bank account statement in OFX format.
  class BankStatement::OFX < BankStatement
    attr_reader :entries

    def initialize(filename, encoding = 'utf-8')
      @entries = []

      # The Global OFX method yields an OFX parser object.
      File.open(filename, "r:#{encoding}") do |io|
        OFX(io) do |p|
          p.bank_accounts.each do |a|
            commodity = Commodity.find_or_create(a.currency)

            # Store all transactions as enumerable entries.
            a.transactions.each do |t|
              date = t.posted_at.to_date
              description = t.name
              description << " (#{t.memo})" if t.memo and !t.memo.empty?

              amount = Amount.new commodity, t.amount
              transactions = [Transaction.new(a.id, amount)]

              entry = Entry.new(date, nil, nil, nil, description, transactions)
              @entries << entry
            end
          end
        end
      end
    end

    # Iterates over each entry in @entries or returns an +Enumerator+
    # when called without a block.
    def each(&block)
      @entries.each(&block)
    end
  end

end

require 'monkey'

module Monkey::Business

  class Config < Monkey::Config
    attr_accessor :default_receivable_account
    attr_accessor :default_sales_account
    attr_accessor :default_tax_account

    attr_accessor :default_payable_account
    attr_accessor :default_purchases_account
    attr_accessor :default_input_tax_account

    attr_reader :default_hourly_rate

    attr_accessor :ledger_file

    def initialize(options = {})
      @default_receivable_account = 'Assets:Accounts Receivable'
      @default_sales_account = 'Income:Sales'
      @default_tax_account = 'Liabilities:Tax'

      @default_payable_account = 'Liabilities:Accounts Payable'
      @default_purchases_account = 'Expenses:Purchases'
      @default_input_tax_account = 'Assets:Input tax'

      self.default_hourly_rate = '$0'

      @ledger_file = nil

      super
    end

    def default_hourly_rate=(value)
      @default_hourly_rate = Monkey::Accounting::Amount.coerce(value)
    end
  end

end

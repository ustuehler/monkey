require 'monkey'

module Monkey::Accounting

  class Config < Monkey::Config

    attr_accessor :default_ledger_file
    attr_accessor :default_income_account
    attr_accessor :default_expenses_account

    def initialize(options = {})
      @default_ledger_file = nil
      @default_income_account = "Income:Unknown"
      @default_expenses_account = "Expenses:Unknown"

      super
    end

  end

end

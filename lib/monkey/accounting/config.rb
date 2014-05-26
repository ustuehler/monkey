require 'monkey'

module Monkey::Accounting

  class Config < Monkey::Config

    attr_accessor :default_ledger_file
    attr_accessor :default_income_account
    attr_accessor :default_expenses_account
    attr_accessor :bank_accounts
    attr_accessor :equity_accounts
    attr_accessor :asset_accounts
    attr_accessor :liability_accounts
    attr_accessor :income_accounts
    attr_accessor :expense_accounts

    def initialize(options = {})
      @default_ledger_file = nil
      @default_income_account = "Income:Unknown"
      @default_expenses_account = "Expenses:Unknown"
      @bank_accounts = ["Assets:Bank"]
      @equity_accounts = ["Equity"]
      @asset_accounts = ["Assets"]
      @liability_accounts = ["Liabilities"]
      @income_accounts = ["Income"]
      @expense_accounts = ["Expenses"]

      super
    end

  end

end

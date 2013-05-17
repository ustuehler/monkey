require 'monkey/business'

module Monkey::Business

  class Config < Monkey::Config
    attr_accessor :default_receivable_account
    attr_accessor :default_sales_account
    attr_accessor :default_tax_account

    def initialize(options = {})
      @default_receivable_account = 'Assets:Accounts Receivable'
      @default_sales_account = 'Income:Sales'
      @default_tax_account = 'Liabilities:Tax'

      super
    end
  end

end

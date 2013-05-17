require 'monkey/business'

module Monkey::Business

  # Business customer (persistent resource)
  class Customer
    include Resource

    property :id, String, :key => true
    property :name, String
    property :billing_address, String
    property :receivable_account_name, String
    property :sales_account_name, String
    property :tax_account_name, String

    has n, :invoices

    def default_receivable_account_name
      Monkey.config.business.default_receivable_account + ':' + name
    end

    def default_sales_account_name
      Monkey.config.business.default_sales_account
    end

    def default_tax_account_name
      Monkey.config.business.default_tax_account
    end

    def receivable_account
      Monkey::Business.ledger.account(receivable_account_name || default_receivable_account_name)
    end

    def sales_account
      Monkey::Business.ledger.account(sales_account_name || default_sales_account_name)
    end

    def tax_account
      Monkey::Business.ledger.account(tax_account_name || default_tax_account_name)
    end

  end

end

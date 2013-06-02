require 'monkey/business'

module Monkey::Business

  # Business supplier (persistent resource)
  class Supplier
    include Resource

    property :id, String, :key => true
    property :name, String
    property :payable_account_name, String
    property :purchases_account_name, String
    property :input_tax_account_name, String

    has n, :invoices

    def default_payable_account_name
      Monkey.config.business.default_payable_account + ':' + name
    end

    def default_purchases_account_name
      Monkey.config.business.default_purchases_account + ':' + name
    end

    def default_input_tax_account_name
      Monkey.config.business.default_input_tax_account
    end

    def payable_account
      Monkey::Business.ledger.account(payable_account_name || default_payable_account_name)
    end

    def purchases_account
      Monkey::Business.ledger.account(purchases_account_name || default_purchases_account_name)
    end

    def input_tax_account
      Monkey::Business.ledger.account(input_tax_account_name || default_input_tax_account_name)
    end

  end

end

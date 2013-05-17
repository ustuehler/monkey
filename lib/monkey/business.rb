require 'monkey'

module Monkey::Business
  autoload :Config, 'monkey/business/config'
  autoload :Customer, 'monkey/business/customer'
  autoload :Invoice, 'monkey/business/invoice'
  autoload :Resource, 'monkey/business/resource'
  autoload :TimeSheet, 'monkey/business/time_sheet'

  # Return the ledger to use for business accounting.
  #
  # @return [Monkey::Accounting::Ledger]
  #   The ledger instance to use for business accounting.
  def self.ledger
    Monkey::Accounting.default_ledger
  end
end

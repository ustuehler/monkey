require 'monkey'

module Monkey::Business
  autoload :Config, 'monkey/business/config'
  autoload :Customer, 'monkey/business/customer'
  autoload :Invoice, 'monkey/business/invoice'
  autoload :Supplier, 'monkey/business/supplier'
  autoload :TimeSheet, 'monkey/business/time_sheet'

  # Return the ledger to use for business accounting.
  #
  # @return [Monkey::Accounting::Ledger]
  #   The ledger instance to use for business accounting.
  def self.ledger
    if ledger_file = Monkey.config.business.ledger_file
      ledger_file = File.expand_path(ledger_file)
      @ledger ||= Monkey::Accounting::Ledger.load_file(ledger_file)
    else
      Monkey::Accounting.default_ledger
    end
  end
end

require 'monkey/data_mapper/finalize'

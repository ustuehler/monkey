require 'monkey'

# Banking module (typically online banking)
#
# @see Monkey::Accounting
module Monkey::Banking
  autoload :Account, 'monkey/banking/account'
  autoload :Bank, 'monkey/banking/bank'

  # Return the list of known banks.
  def self.banks
    Bank.all
  end

  # Return the list of known bank accounts.
  def self.accounts
    banks.each { |b| b.accounts }.flatten
  end

end

require 'monkey/data_mapper/finalize'

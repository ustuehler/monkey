require 'monkey'

# The main purpose of this module is to automate online-banking tasks.  It
# makes heavy use of the {Accounting::Amount} class to represent monetary
# values.
#
# @example Get the names of all known banks.
#   Monkey::Banking.banks.map { |b| b.name }
#   # => ["Berliner Volksbank", "GLS Gemeinschaftsbank eG"]
#
# @example Get the alias names of all known bank accounts.
#   Monkey::Banking.accounts.map { |a| a.alias }
#   # => ["private", "business", "savings"]
#
# @see Monkey::Accounting
module Monkey::Banking
  autoload :Account, 'monkey/banking/account'
  autoload :Bank, 'monkey/banking/bank'

  # Returns all known banks.
  # @return a collection of {Bank} instances
  def self.banks
    Bank.all
  end

  # Returns all known bank accounts.
  # @return a collection of {Account} instances
  def self.accounts
    Account.all
  end

end

require 'monkey/data_mapper/finalize'

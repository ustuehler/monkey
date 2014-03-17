require 'monkey/banking'

module Monkey::Banking
  # Bank account with name of account holder and an optional alias
  class Account
    include Monkey::DataMapper::Resource

    # bank that this account belongs to
    belongs_to :bank, :key => true, :required => true

    # account number within the bank
    property :number, String, :key => true, :required => true

    # alias to be used as an easy-to-remember account reference
    property :alias, String, :required => false, :unique => true

    # name of the account holder for receiving value transfers
    property :name, String, :required => true
  end
end

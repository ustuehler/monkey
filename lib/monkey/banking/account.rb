require 'monkey/banking'

module Monkey::Banking
  # Bank account with name of account holder and an optional alias
  class Account
    include Monkey::DataMapper::Resource

    # support single-table inheritance
    property :type, Discriminator

    # bank that this account belongs to
    belongs_to :bank, :key => true, :required => true

    # account number within the bank
    property :number, String, :key => true, :required => true

    # alias to be used as an easy-to-remember account reference
    property :alias, String, :required => false, :unique => true

    # name of the account holder for receiving transfers
    property :name, String, :required => true

    # Return a boolean indicating whether this account can be used in online
    # banking (e.g., to issue transfers).
    #
    # The default implementation returns +false+.  Override this method in a
    # subclass to return +true+ if that account type supports online banking.
    def online?
      false
    end

    # Transfer some +amount+ (Monkey::Accounting::Amount) from this account to
    # another account +raccount+.  The reason for transfer can be given as the
    # +purpose+ argument, an array of single-line strings.
    #
    # The default implementation raises an error because this account type
    # does not support online banking.
    def transfer(raccount, amount, purpose = [])
      raise "#{self.inspect} is unavailable for online banking"
    end

    # Return the implementation class for the named account type.  If name is +nil+
    # For example, ``Account.type :hbci`` would return the Account::HBCI class.
    # The type name is case-insensitive and can be a symbol or a string.
    #
    # @param name +nil+, Symbol or a String (case-insensitive)
    # @return Account class
    def self.type(name)
      return self if name == nil
      name = name.to_s.downcase
      unless sym = constants.select {|c| c.to_s.downcase == name}.first
        raise "undefined type of #{self}: #{name.inspect}"
      end
      klass = const_get(sym)
      unless klass <= self
        raise "#{klass} is not a #{self} - invalid type #{name.inspect}"
      end
      klass
    end
  end
end

require 'monkey/banking/account/hbci'

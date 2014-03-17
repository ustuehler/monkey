require 'monkey/banking'

module Monkey::Banking
  # Bank with usually one or more bank accounts
  class Account
    include Monkey::DataMapper::Resource

    property :number, String, :key => true
    property :name, String

    belongs_to :bank, :key => true, :required => true
  end
end

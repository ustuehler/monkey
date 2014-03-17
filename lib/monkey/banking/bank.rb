require 'monkey/banking'

module Monkey::Banking
  # Bank with usually one or more bank accounts
  class Bank
    include Monkey::DataMapper::Resource

    property :id, String, :key => true, :unique => true
    property :name, String
    property :code, String

    has n, :accounts
  end
end

require 'monkey'

module Monkey::Accounting

  class BankStatement::Config < Monkey::Config

    attr_accessor :csv_formats

    def initialize(options = {})
      # TODO: add some predefined formats
      @csv_formats = {}

      super(options)
    end

  end

end

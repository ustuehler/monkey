require 'monkey'

module Monkey::ProcessMail

  # Represents the global configuration settings for +ProcessMail+.
  class Config < Monkey::Config

    # It this attribute is +true+, allows user interaction; otherwise,
    # a default answer may be assumed or an error raised wherever user
    # interaction is needed.
    attr_accessor :interactive

    # If this attribute is +true+, the +ProcessMail+ rules may act
    # on matched messages; otherwise, they are obliged to just show
    # what would be done.
    attr_accessor :noop

    # Initializes the configuration for +ProcessMail+.
    def initialize(options = {})
      @interactive = false
      @noop = false

      super
    end

  end

end

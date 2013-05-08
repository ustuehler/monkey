require 'monkey'

module Monkey::ProcessMail

  # Global configuration settings for Monkey::ProcessMail
  class Configuration

    # Whether to allow user interaction through HighLine methods.
    attr_accessor :interactive

    # Whether to actually act on mail or to just show what would
    # be done.
    attr_accessor :noop

    # Create the default configuration for Monkey::ProcessMail.
    # @return [Configuration] a default configuration
    def initialize
      @interactive = false
      @noop = false
    end

  end

end

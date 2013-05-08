require 'forwardable'

require 'highline'
require 'mailman'
require 'rake'
require 'rspec/expectations'
require 'rspec/matchers'

require 'monkey'

module Monkey::ProcessMail

  # Special kind of Mailman application which reads a single message
  # from STDIN and then re-opens STDIN from the controlling terminal
  # before processing it.
  #
  # Route matching code can also use Monkey::ProcessMail application
  # configuration via the #config method, RSpec expectations and
  # matchers, Rake::FileUtilsExt#sh and (some) HighLine methods.
  class Application < Mailman::Application

    # Access the application configuration, which is cloned initially
    # from the global configuration Monkey::ProcessMail.config.
    attr_reader :config

    def initialize(&block)
      # Avoid passing an implicit block to super because we extend
      # the router (created by super) with additional methods that
      # the block can then use.  http://goo.gl/OJST1
      super(&nil)

      @config = Monkey::ProcessMail.config.clone

      # Make some additional methods available to all route providers.
      app = self
      router.instance_eval do
        extend RSpec::Matchers
        extend Rake::FileUtilsExt

        extend Forwardable
        @highline = HighLine.new
        def_delegators :@highline, :ask, :agree

        @app = app
        def_delegators :@app, :config
      end

      # Evaluate the block, now that additional methods are there.
      instance_eval(&block) if block_given?
    end

    # Process a single e-mail message.
    #
    # This replaces the use of Mailman::Application#run, because that
    # method would read and process the message on STDIN before we get
    # a chance to re-open STDIN from the controlling terminal.  This
    # also means that we don't have to touch Mailman.config.rails_root
    # to disable the automatic loading of a Rails environment.
    def process(message)
      # Process a plain text and MIME encoded e-mail message.
      processor.process message
    end

  end

end

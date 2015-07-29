# Monkey is the top-level module for all components of my "home and office
# monkey", my personal tool to automate all the things which I don't like to do
# manually.
#
# == Components
#
# The main components of Monkey and their purpose are:
#
# - {Accounting} is to maintain an accounting ledger.
# - {Banking} is to automate online-banking tasks.
# - {Business} is to automate routine tasks for small businesses.
# - {ProcessMail} is to handle known e-mail messages automatically.
#
# == Configuration
#
# Components that need user-provided configuration data should define a
# subclass of {Config} in their own module (e.g., {Business::Config}).  The
# {Config} class abstracts the loading of configuration data from files and
# lets the component define reasonable defaults for values that the user hasn't
# set.  The global configuration can be accessed at run-time via {config}.  It
# is loaded automatically from {config_file} if that file exists when {config}
# is called for the first time.
#
# == Database Storage
#
# Components that need to maintain records in a database should define
# persistent object classes that include Monkey's own
# {Monkey::DataMapper::Resource}.  See {Banking::Account} for an example.
module Monkey
  autoload :Accounting, 'monkey/accounting'
  autoload :Banking, 'monkey/banking'
  autoload :Business, 'monkey/business'
  autoload :Config, 'monkey/config'
  autoload :DataMapper, 'monkey/data_mapper'
  autoload :ProcessMail, 'monkey/process_mail'
  autoload :VERSION, 'monkey/version'

  # Returns the path to a directory where additional commands are loaded from.
  #
  # @return [String] an absolute pathname
  def self.commands_path
    File.expand_path '~/.monkey/commands'
  end

  # Returns the filename of the global configuration file in the current user's
  # home directory.
  #
  # @return [String] an absolute pathname
  def self.config_file
    File.expand_path '~/.monkey/config.yml'
  end

  # Returns the current run-time configuration for all {Monkey} components.
  # The file named by {config_file} will be loaded if it exists when this
  # method is first called; otherwise, a default configuration is assumed.  Any
  # values changed at run-time will not persist across a restart of the Ruby
  # interpreter.  To make permanent changes the configuration file itself has
  # to be edited.
  #
  # @return [Config] the current run-time configuration
  #
  # @see config_file
  # @see default_config
  def self.config
    @config ||= File.exists?(config_file) ? Config.load_file(config_file) :
      default_config
  end

  # Returns the default configuration that will be used if the global
  # configuration file does not exist when {config} is first called.  Any
  # values changed in the returned {Config} instance will only affect that
  # instance as this method will return a new instance every time it is called.
  #
  # @return [Config] a new default configuration instance
  def self.default_config
    Config.new
  end
end

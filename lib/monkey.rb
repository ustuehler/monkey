# +Monkey+ is the root module for all components of my "home and office
# monkey" - a toolbox that automates things I don't like to do manually.
#
# The configuration for all modules is managed via the {Monkey::Config}
# class.  The current global configuration, which is normally parsed from
# a configuration file, can be retrieved via {Monkey.config}.
#
# @see Monkey::Accounting
# @see Monkey::Business
# @see Monkey::ProcessMail
# @see Monkey.config
module Monkey
  autoload :Accounting, 'monkey/accounting'
  autoload :Business, 'monkey/business'
  autoload :Config, 'monkey/config'
  autoload :DataMapper, 'monkey/data_mapper'
  autoload :ProcessMail, 'monkey/process_mail'
  autoload :VERSION, 'monkey/version'

  # Returns the run-time configuration for all {Monkey} modules.
  #
  # If {config_file} exists, loads the file using {load_config} and
  # remembers the {Config} instance.  If the file does not exist, the
  # instance returned by {default_config} is remembered instead.
  #
  # Any values changed at run-time will not persist across a restart
  # of the Ruby interpreter.  To persist changes, the configuration
  # file must currently be edited by hand.
  #
  # @return [Config]  The global run-time configuration instance.
  def self.config
    @config ||= File.exists?(config_file) ? load_config(config_file) :
      default_config
  end

  # Returns the absolute path to the global configuration file for all
  # {Monkey} modules.
  #
  # @return [String]  The absolute path to a file in YAML format, which
  #  may or may not exist.
  def self.config_file
    File.expand_path '~/.monkey/config.yml'
  end

  # Returns a new {Config} instance.
  #
  # The instance returned represents the configuration that will be used
  # if the {config_file} does not exist when the {config} method is first
  # called.
  def self.default_config
    Config.new
  end

  # Parses the given `filename` (a YAML file) and return a new {Config}
  # instance for it.
  #
  # @param [String] filename  The name of an existing file to parse.
  # @return [Config]  The configuration that was loaded from the file.
  def self.load_config(filename)
    Config.load_file filename
  end

end

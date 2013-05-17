module Monkey
  autoload :Accounting, 'monkey/accounting'
  autoload :Business, 'monkey/business'
  autoload :Config, 'monkey/config'
  autoload :ProcessMail, 'monkey/process_mail'

  def self.default_config
    Config.new
  end

  def self.load_config(filename)
    Config.load_file filename
  end

  def self.config_file
    File.expand_path '~/.monkey/config.yml'
  end

  def self.config
    @config ||= File.exists?(config_file) ? load_config(config_file) :
      default_config
  end

end

require 'monkey'

module Monkey::ProcessMail
  autoload :Application, 'monkey/process_mail/application'
  autoload :TimeRecording, 'monkey/process_mail/time_recording'
  autoload :Configuration, 'monkey/process_mail/configuration'

  # Access the global Monkey::ProcessMail configuration.
  # @return [Configuration]
  def self.config
    @config ||= Configuration.new
  end
end

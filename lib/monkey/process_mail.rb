require 'monkey'

# +Monkey::ProcessMail+ is the root module for an application which
# matches e-mail messages based on certain criteria (such as sender,
# subject or attachments) and then acts on the message as appropriate.
#
# @see Application
# @see config
module Monkey::ProcessMail
  autoload :Application, 'monkey/process_mail/application'
  autoload :Config, 'monkey/process_mail/config'
  autoload :TimeRecording, 'monkey/process_mail/time_recording'

  # Returns the global configuration for the +ProcessMail+ module.
  def self.config
    Monkey.config.process_mail
  end
end

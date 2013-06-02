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

  # Autoload all user-defined route providers.
  Dir.glob(File.expand_path '~/.monkey/process_mail/*.rb').sort.each do |file|
    const_name_candidates = File.read(file).lines.
      grep(/^\s*([A-Z][^\s]*)\s*=\s*(?:proc|lambda)/) { |v|
        $1.split('::').last
      }

    const_name = const_name_candidates.find { |name|
      underscore_name = name.
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase

      # A proc or lambda assigned to the "FooBar" const will be
      # used as the autoload symbol if the file name is "foo_bar.rb"
      # or "foobar.rb".
      basename = File.basename(file, '.rb')
      basename == underscore_name or basename == name.downcase
    }

    # Silently skip this file if no matching proc or lambda
    # constant was found inside.
    unless const_name
      warn "WARNING: can't find matching constant in #{file}"
      next
    end

    autoload const_name.to_sym, file.sub(/\.rb$/, '')
  end
end

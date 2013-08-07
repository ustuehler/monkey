require 'pathname'

require 'monkey/process_mail'

module Monkey::ProcessMail

  TimeRecording = proc do

    time_recording_dir = File.expand_path "~/.monkey/business/time-recording"

    subject(/Time Recording Report E4/) do
      message.attachments.size.should == 1

      attachment = message.attachments.first
      attachment.content_type.should match(/^text\/(csv|comma-separated-values);/)
      attachment.content_type_parameters.should include("name")

      filename = attachment.content_type_parameters['name']
      filename.should match(/^timerec\.\d+\.\d+\.e4\.csv$/)

      puts "Processing attachment #{filename}"
      next if config.noop

      Pathname(time_recording_dir).should be_directory
      Dir.chdir(time_recording_dir) do
        puts "(in #{time_recording_dir})"

        if File.file?(filename) and
          config.interactive and
          agree("Replace #{filename}? (yes/no): ")

          File.unlink filename
        end

        Pathname(filename).should_not exist
        File.open(filename, 'w') do |io|
          io.write attachment.decoded
        end

        if not config.interactive or agree("Run rake? (yes/no): ")
          sh "rake"
        end
      end
    end

  end

end

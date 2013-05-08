require 'pathname'

require 'monkey/process_mail'

Monkey::ProcessMail::TimeRecording = proc do

  TIME_RECORDING_DIR = File.expand_path "~/.monkey/time-recording"

  subject(/Time Recording Report E4/) do
    message.attachments.size.should == 1

    attachment = message.attachments.first
    attachment.content_type.should start_with("text/comma-separated-values;")
    attachment.content_type_parameters.should include("name")

    filename = attachment.content_type_parameters['name']
    filename.should match(/^timerec\.\d+\.\d+\.e4\.csv$/)

    puts "Processing attachment #{filename}"
    next if $noop

    Pathname(TIME_RECORDING_DIR).should be_directory
    Dir.chdir(TIME_RECORDING_DIR) do
      puts "(in #{TIME_RECORDING_DIR})"

      if File.file?(filename) and
        agree("Replace #{filename}? (yes/no): ")

        File.unlink filename
      end

      Pathname(filename).should_not exist
      File.open(filename, 'w') do |io|
        io.write attachment.decoded
      end

      if agree("Run rake? (yes/no): ")
        sh "rake"
      end
    end
  end

end

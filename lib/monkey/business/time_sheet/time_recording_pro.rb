require 'monkey/business'

module Monkey::Business


  # "E4" data export from the "Time Recording Pro" Android application
  #
  # The underlying file format is CSV (comma-separated values) and the
  # file name of the e-mail attachemnt when the report is sent via mail
  # should match the shell glob pattern "timerec.*.e4.csv".
  class TimeSheet::TimeRecordingPro < TimeSheet

    # Open the specified file with the specified encoding and return a
    # parser for it.
    #
    # @param [String] filename
    # @param [String] encoding
    # @return [TimeSheet::TimeRecordingPro]
    def self.load_file(filename, encoding = 'ISO-8859-1')
      new File.open(filename, "r:#{encoding}")
    end

    # Create a time recording report parsing lines from `input'.
    # Use #each to iterate over all work items in the report.
    #
    # @param [IO, #readline] input a line-based input stream of CSV data
    def initialize(input)
      super()
      @io = input
      @eof = false
      @lineno = 0
      @fields = nil
      @separator = ';'
      parse!
    end

    private

    def parse!
      while line = readline
        row = line.chomp.split(@separator)

        if @lineno == 1
          @fields = row
        elsif row[0] == 'Total'
          # discard the rest
          @eof = true
        else
          rec = {}
          row.each_with_index do |value, i|
            # Transform known fields.
            case field = @fields[i]
            when 'Date'
              field = :date
              value = Date.parse(value)
            when 'Day'
              # Discard "Day", because it is implied by the "Date".
              next
            when 'Total (decimal)'
              field = :time
              value = value.to_f
            when 'Total'
              field = :time
              # Convert HH:MM time format to decimal.
              if value =~ /^\d+:\d{2}$/
                hours, minutes = value.split(':')
                value = hours.to_f + (minutes.to_f / 60.0)
              else
                raise "couldn't find time in row #{line.inspect}"
              end
            when 'Customer', 'Client'
              field = :client
            when 'Work unit notes'
              field = :notes
            end

            rec[field] = value
          end

          # Add this record.
          self << rec
        end
      end
    end

    def readline
      return nil if @eof

      begin
        line = @io.readline
        @lineno += 1
        line
      rescue EOFError
        @eof = true
        @io.close rescue nil
        nil
      end
    end

  end

end

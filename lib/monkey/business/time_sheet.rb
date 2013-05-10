require 'date'

require 'monkey/business'

module Monkey::Business

  # Time sheet (work hour tracking)
  #
  # A time sheet is a set of records in an unspecified order, where each
  # record contains a date, client name, working time and work notes.
  # Normally there will be only one record per day, but multiple records
  # may also exist for the same day and even the same client.
  #
  # Time sheets may contain tracking information for multiple clients and
  # spanning less than one or more than one month.  
  class TimeSheet
    autoload :TimeRecordingPro, 'monkey/business/time_sheet/time_recording_pro'

    # daily records in this time sheet
    attr_reader :records

    # Load a time sheet file.  A time sheet file can contain tracking
    # information for less than or more than one month.
    #
    # @param [String] filename the path to time sheet file
    # @param [Symbol] format the symbolic name of the time sheet file
    #   format, or :auto to use the file name to determine the format.
    #   The symbol should be the name of a class in the
    #   Monkey::Business::TimeSheet namespace.
    #
    # @return [TimeSheet] a time sheet
    def self.load_file(filename, format = :auto)
      if self != Monkey::Business::TimeSheet
        raise "#{self}.load_file not implemented"
      end

      if format == :auto
        if File.basename(filename) =~ /^timerec\..*\.e4\.csv$/
          format = :TimeRecordingPro
        else
          raise "unrecognized time sheet file name pattern: " +
            "#{filename}; can't determine the file format"
        end
      end

      klass = const_get(format)
      klass.load_file filename
    end

    # Create an empty time sheet.
    def initialize
      @records = []
    end

    # Append a new day record.  Using this method, records may
    # be added in arbitrary order.
    #
    # @param [Hash] record
    def <<(record)
      @records << record
    end

    # Return the total hours recorded in the time sheet.
    #
    # @return [Float] total number of work hours
    def total
      total_time = 0.0
      each { |record| total_time += record[:time] }
      total_time
    end

    # Return the earliest date of any record in this time sheet.
    #
    # @return [Date, nil] a date object or nil if the sheet is empty
    def start_date
      @records.min { |a,b| a[:date] <=> b[:date] }[:date]
    end

    # Return the latest date of any record in this time sheet.
    #
    # @return [Date, nil]
    def end_date
      @records.max { |a,b| a[:date] <=> b[:date] }[:date]
    end

    # Iterate over all work day records in the report.
    #
    # @yieldparam [Hash] rec a work day record
    def each(&block)
      @records.each(&block)
    end

    # Return a list of clients referenced in this time sheet.
    #
    # @return [Array<String>] a list of client names
    def clients
      clients = []
      each { |rec| clients << rec[:client] }
      clients.uniq
    end

    # Return a new time sheet containing only the records for
    # the given client.
    #
    # @return [TimeSheet] a new time sheet instance
    def for_client(client)
      time_sheet = TimeSheet.new
      each { |record| time_sheet << record if record[:client] == client }
      time_sheet
    end

    # Return a new time sheet containing only records which fall
    # between the given start and end date, inclusive.
    #
    # @param [Date] start_date the start date
    # @param [Date] end_date the end date
    #
    # @return [TimeSheet] a new time sheet instance
    def between_dates(start_date, end_date)
      start_date = coerce_date(start_date)
      end_date = coerce_date(end_date)
      time_sheet = TimeSheet.new
      each do |record|
        time_sheet << record if record[:date] >= start_date and
          record[:date] <= end_date
      end
      time_sheet
    end

    # Yield a new time sheet for each client.
    #
    # @yieldparam [String] client
    # @yieldparam [TimeSheet] time_sheet
    def each_client(&block)
      clients.each do |client|
        time_sheet = for_client(client)
        yield(client, time_sheet)
      end
    end

    private

    # Coerce the given value into a Date object.
    #
    # @param [Date,String] value the value to coerce.  If it's already
    #   a Date object, the value itself will be returned.  If it's a
    #   String, the value will be parsed using the Date.parse method.
    #
    # @return [Date]
    def coerce_date(value)
      case value
      when Date
        value
      when String
        Date.parse(value)
      else
        raise ArgumentError, "expected: Date or String, got: " +
          value.inspect
      end
    end

  end

end

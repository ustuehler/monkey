require 'open3'
require 'monkey/banking'

# Wrapper for aqbanking-cli with transaction logging.
class Monkey::Banking::AqBanking
  class Config < Monkey::Config
    attr_accessor :cli
    attr_accessor :pinfile

    def initialize(options = {})
      @cli = 'aqbanking-cli'
      super
    end
  end

  def initialize
  end

  def balance
    context_file do |ctxfile|
      request :balance, ctxfile
      listbal ctxfile
    end
  end

  # Base class for errors raised by {AqBanking}.
  class Error < RuntimeError
  end

  # Raised if an "aqbanking-cli" command fails.
  class CommandError < Error
    attr_reader :command, :status, :output

    def initialize(cmd, status, output)
      @command, @status, @output = cmd, status, output
      super "#{cmd.first} command exited with non-zero status code #{status}"
    end
  end

  # Raised if the output of an "aqbanking-cli" command could not be parsed.
  class ParseError < Error
    attr_reader :command

    def initialize(command, message)
      @command = command
      super message
    end
  end

  private

  def request(what, ctxfile)
    cmd = cli_cmd('request', "--#{what}", "--ctxfile=#{ctxfile}")
    output, status = Open3.capture2e(*cmd)
    raise RequestError.new(cmd, status, output) if status != 0
  end

  def listbal(ctxfile)
    cmd = cli_cmd('listbal', "--ctxfile=#{ctxfile}")
    stdout, stderr, status = Open3.capture3(*cmd)
    raise CommandError.new(cmd, status, stderr) if status != 0

    # Parse the output.  Each line of output must begin with the constant
    # string "Account" and is followed by a fixed number of tab-separated
    # fields.
    stdout.lines.each.map { |line|
      keyword, bank_code, account_number, bank_name, account_name,
        booked_date, booked_time, booked_quantity, booked_currency,
        noted_date, noted_time, noted_quantity, noted_currency =
        line.split("\t")

     if keyword != "Account"
        raise ParseError.new(cmd, "expected \"Account\", but got #{keyword.inspect}")
     end

     balance = {bank_code: bank_code, account_number: account_number}

     balance[:bank_name] = bank_name unless bank_name.empty?
     balance[:account_name] = account_name unless account_name.empty?
     balance[:booked_date] = DateTime.parse("#{booked_date} #{booked_time}")
     balance[:booked_amount] = Monkey::Accounting::Amount.new(booked_currency, booked_quantity)

     unless noted_date.empty? or noted_time.empty?
       balance[:noted_date] = DateTime.parse("#{noted_date} #{noted_time}")
     end

     unless noted_quantity.empty? or noted_currency.empty?
       balance[:noted_amount] = Monkey::Accounting::Amount.new(noted_currency, noted_quantity)
     end

     # Map this line to a hash map.
     balance
    }
  end

  def context_file(&block)
    ctxfile = Tempfile.new('ctx')
    begin
      ctxfile.close
      yield ctxfile.path
    ensure
      ctxfile.unlink
    end
  end

  def pinfile
    File.expand_path Monkey.config.banking.aq_banking.pinfile
  end

  def cli_cmd(command, *args)
    cmd = [Monkey.config.banking.aq_banking.cli]
    cmd << '--noninteractive'
    cmd << "--pinfile=#{pinfile}"
    cmd << command
    cmd += args
    cmd
  end
end

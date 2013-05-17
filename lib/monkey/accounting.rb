require 'monkey'

module Monkey::Accounting
  autoload :Ledger, 'monkey/accounting/ledger'

  # Return the default ledger file to use for personal accounting.
  def self.default_ledger_file
    return ENV['LEDGER_FILE'] if ENV.has_key? 'LEDGER_FILE'

    ledgerrc = File.expand_path('~/.ledgerrc')

    if File.exists? ledgerrc
      File.open(ledgerrc, 'r') do |f|
        re = /^\s*(?:-f|--file)(?:=?|\s+)([^\s].*)$/
        if f.read.lines.any? { |line| line.match(re) }
          ledger_file = $1
          return File.expand_path(ledger_file)
        end
      end
    end

    raise "no ledger file set in ~/.ledgerrc or LEDGER_FILE"
  end

  # Return the default ledger instance for personal accounting.
  def self.default_ledger
    @ledger ||= Ledger.load_file default_ledger_file
  end
end

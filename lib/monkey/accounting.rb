require 'monkey'

# This module deals with financial accounting.
#
# @see Monkey::Accounting::Ledger
# @see default_ledger
module Monkey::Accounting
  autoload :Ledger, 'monkey/accounting/ledger'

  # Returns the file name of the default ledger, which may or may not
  # exist initially.
  #
  # The file name is derived from the environment variable LEDGER_FILE
  # or from the --file (or -f) option in the user's ~/.ledgerrc file.
  #
  # @return [String]  The file name of the default ledger.
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

  # Returns the default ledger loaded from {default_ledger_file}.
  #
  # @return [Ledger]  The default ledger.
  def self.default_ledger
    @ledger ||= Ledger.load_file default_ledger_file
  end
end

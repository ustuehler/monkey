require 'monkey'

# This module deals with financial accounting.
#
# @see Monkey::Accounting::Ledger
# @see default_ledger
module Monkey::Accounting
  autoload :Amount, 'monkey/accounting/amount'
  autoload :BankStatement, 'monkey/accounting/bank_statement'
  autoload :Commodity, 'monkey/accounting/commodity'
  autoload :Config, 'monkey/accounting/config'
  autoload :Entry, 'monkey/accounting/entry'
  autoload :Ledger, 'monkey/accounting/ledger'
  autoload :Transaction, 'monkey/accounting/transaction'

  # Returns the file name of the default ledger.  The file name is
  # looked up in the following order (first non-empty value wins):
  #
  # 1. Result of {Monkey.config}.accounting.default_ledger_file
  # 2. Environment variable +LEDGER_FILE+
  # 3. +--file+ (or +-f+) option in +~/.ledgerrc+ file
  def self.default_ledger_file
    if filename = Monkey.config.accounting.default_ledger_file
      return File.expand_path(filename)
    end

    if ENV.has_key? 'LEDGER_FILE'
      return File.expand_path(ENV['LEDGER_FILE'])
    end

    if File.exists?(ledgerrc = File.expand_path('~/.ledgerrc'))
      File.open(ledgerrc, 'r') do |f|
        re = /^\s*(?:-f|--file)(?:=?|\s+)([^\s].*)$/
        if f.read.lines.any? { |line| line.match(re) }
          filename = $1
          return File.expand_path(filename)
        end
      end
    end

    raise "no default ledger filename configured"
  end

  # Returns the default ledger loaded from {default_ledger_file}.
  #
  # @return [Ledger]  The default ledger.
  def self.default_ledger
    @ledger ||= Ledger.load_file default_ledger_file
  end

end

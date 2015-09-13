require 'monkey/accounting'

module Monkey::Accounting

  # Single transaction describing the amount transferred to or from an
  # account.
  class Transaction

    attr_accessor :account
    attr_accessor :amount
    attr_accessor :note

    # A +Transaction+ is initialized using the an +Account+ and an
    # +Amount+, which are simply stored as instance variables.  An
    # optional note can also be given.
    def initialize(account, amount, note = nil)
      @account, @amount, @note = account, amount, note
    end

    # Formats the transaction for display.  The display format of a
    # +Transaction+ is compatible with the ledger CLI tool (see
    # http://ledger-cli.org).
    def to_s
      "    #{account}" +
        (amount ? "  #{amount}" : "") +
        (note ? "  ; #{note}" : "")
    end

  end

end

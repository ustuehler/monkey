require 'monkey/accounting'

module Monkey::Accounting

  # This class represents an abstract bank statement.  Nested subclasses
  # of this class will parse or generate statements in specific formats.
  class BankStatement
    autoload :CSV, 'monkey/accounting/bank_statement/csv'
    autoload :OFX, 'monkey/accounting/bank_statement/ofx'
    autoload :Config, 'monkey/accounting/bank_statement/config'

    include Enumerable
  end

end

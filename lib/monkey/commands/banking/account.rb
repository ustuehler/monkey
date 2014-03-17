desc 'Manage accounts, and not just your own'

long_desc <<EOS
Manage bank accounts linked to some previously defined bank.  Bank accounts are
identified primarily by the unique account number within the bank to which it
is linked.  An account can also be identified by an alias such as "savings" or
"business".  The account alias must be unique for all banks, if set.

If you use an account regularly to transfer money to it, set the account holder
name property so that you don't have to specifiy it for every transfer again.
EOS

command :account do |c|
  c.commands_from 'monkey/commands/banking/account'
end

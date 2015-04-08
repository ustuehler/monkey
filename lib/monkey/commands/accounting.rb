desc 'Manage the accounting ledger'

long_desc <<EOS
Accounting commands can show your account balances, retrieve transactions and
issue transfers, for example.
EOS

command :accounting do |c|
  c.commands_from 'monkey/commands/accounting'
end

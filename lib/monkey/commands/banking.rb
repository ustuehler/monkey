desc 'Deal with banks, typically online'

long_desc <<EOS
Banking commands can show your account balances, retrieve transactions and
create new transactions, for example.
EOS

command :banking do |c|
  c.commands_from 'monkey/commands/banking'
end

desc 'Manage banks, but not bank accounts'

long_desc <<EOS
Manage banks, but not bank accounts.  Every bank has a unique alphanumeric
identifier and a display name.  Use the `show' subcommand without arguments
to list all banks.
EOS

command :bank do |c|
  c.commands_from 'monkey/commands/banking/bank'
end

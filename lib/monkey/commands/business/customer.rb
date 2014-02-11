desc 'Manage beneficiaries of my goods and services'

long_desc <<EOS
Manage customer accounts.  Every customer has a unique alphanumeric
identifier and a display name.  Use the `show' command without arguments
to list all customers.
EOS

command :customer do |c|
  c.commands_from 'monkey/commands/business/customer'
end

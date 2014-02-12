desc 'Manage outgoing customer invoices'

command :invoice do |c|
  c.commands_from 'monkey/commands/business/customer/invoice'
end

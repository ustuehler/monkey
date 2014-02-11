desc 'Manage customers, suppliers, offers, invoices and such'

long_desc <<EOS
Business-related commands deal with customers, suppliers, offers,
invoices (incoming and outgoing), taxes and such things.
EOS

command :business do |c|
  c.commands_from 'monkey/commands/business'
end

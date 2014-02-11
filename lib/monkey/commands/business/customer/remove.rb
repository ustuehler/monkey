desc 'Remove a customer account'

long_desc 'Permanently remove a customer account.

Be very careful, this command cannot be undone!'

arg_name '<id>'

command :remove do |c|
  c.action do |global_options, options, args|
    help_now!('too many arguments') if args.size > 1
    help_now!('missing <id>') if args.size == 0

    customer = Monkey::Business::Customer.get!(args.first)
    customer.destroy
  end
end

desc 'Create a new customer account'
long_desc 'Create a new customer account.

The value of <id> can be chosen freely, but it should consist only of
alphanumeric characters, digits and dashes or underscores.'

arg_name '<id>'

command :add do |c|
  c.desc 'Display name (for invoices and so on)'
  c.flag :name, :arg_name => 'string', :required => true

  c.action do |global_options, options, args|
    help_now!('too many arguments') if args.size > 1
    help_now!('missing <id>') if args.size == 0
    help_now!('missing --name') unless options[:name]

    customer_id = args.first

    if Monkey::Business::Customer.get(customer_id)
      exit_now! "duplicate customer id: #{customer_id}"
    end

    Monkey::Business::Customer.create :id => customer_id,
      :name => options[:name]
  end
end

desc 'Update customer account details'

long_desc 'Update customer account details.  Attributes can be set to
an empty string to unset the value in the account database and assume
defaults whenever possible.'

arg_name '<customer>...'

command :update do |c|
  c.desc 'Hourly rate as a currency amount'
  c.flag 'hourly-rate'

  c.desc 'Address to put on printed invoices (multiline)'
  c.flag 'billing-address'

  c.action do |global_options, options, args|
    help_now!('missing list of customer(s) to update') if args.size == 0

    args.each do |customer_id|
      customer = Monkey::Business::Customer.get!(customer_id)

      case options['hourly-rate']
      when nil
        # don't change
      when ''
        customer.hourly_rate = nil
      else
        customer.hourly_rate = options['hourly-rate']
      end

      case options['billing-address']
      when nil
        # don't change
      when ''
        customer.billing_address = nil
      else
        customer.billing_address = options['billing-address']
      end

      customer.save!
    end
  end
end

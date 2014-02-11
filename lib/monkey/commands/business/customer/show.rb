desc 'Show the list of customers or details for some'

# The following doesn't affect help output as of gli-2.9.0:
#arg_name 'id', [:optional, :multiple]
arg_name '[<id>...]'

long_desc <<EOS
Show the list of all customer accounts (without arguments) or
details for one or more accounts identified by <id>.
EOS

customer_formatter = lambda do |customer|
  <<-EOS
* customer #{customer.id}
  Name: #{customer.name}
  Billing address:
    #{customer.billing_address || "(none)"}
  Receivable account: #{customer.receivable_account_name ||
    "#{customer.default_receivable_account_name} (default)"}
  Sales account: #{customer.sales_account_name ||
    "#{customer.default_sales_account_name} (default)"}
  Tax account: #{customer.tax_account_name ||
    "#{customer.default_tax_account_name} (default)"}
  Hourly rate: #{customer.hourly_rate ||
    "#{customer.default_hourly_rate} (default)"}
  Number of invoices: #{customer.invoices.size}
  EOS
end

command :show do |c|
  c.action do |global_options, options, args|
    if args.size == 0
      Monkey::Business::Customer.all.each do |customer|
        puts customer.id
      end
    else
      args.each do |customer_id|
        customer = Monkey::Business::Customer.get!(customer_id)
        puts customer_formatter.call(customer)
      end
    end
  end
end

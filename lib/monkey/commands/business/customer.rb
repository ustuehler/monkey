desc 'Query and manipulate customer data'

long_desc <<EOS
Query and manipulate customer data.  Every customer has at least a
unique symbolic identifier and a display name.  Use the `show' command
without arguments to list all currently defined customer identifiers.
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

command :customer do |c|
  c.desc 'List all customer IDs or show customer details'
  c.command :show do |show|
    show.action do |global_options, options, args|
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
end

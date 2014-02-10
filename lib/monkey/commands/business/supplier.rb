desc 'Query and manipulate supplier data'

long_desc <<EOS
Query and manipulate supplier data.  Every supplier has at least a
unique symbolic identifier and a display name.  Use the `show' command
without arguments to list all currently defined supplier identifiers.
EOS

supplier_formatter = lambda do |supplier|
  <<-EOS
* supplier #{supplier.id}
  Name: #{supplier.name}
  Payable account: #{supplier.payable_account_name ||
    "#{supplier.default_payable_account_name} (default)"}
  Purchases account: #{supplier.purchases_account_name ||
    "#{supplier.default_purchases_account_name} (default)"}
  Input tax account: #{supplier.input_tax_account_name ||
    "#{supplier.default_input_tax_account_name} (default)"}
  Number of invoices: #{supplier.invoices.size}
  EOS
end

command :supplier do |c|
  c.desc 'List all supplier IDs or show supplier details'
  c.command :show do |show|
    show.action do |global_options, options, args|
      if args.size == 0
        Monkey::Business::Supplier.all.each do |supplier|
          puts supplier.id
        end
      else
        args.each do |supplier_id|
          supplier = Monkey::Business::Supplier.get!(supplier_id)
          puts supplier_formatter.call(supplier)
        end
      end
    end
  end
end

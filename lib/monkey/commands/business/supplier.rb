desc 'manage suppliers of goods and services to me'

long_desc <<EOS
Manage supplier accounts.  Every supplier has a unique alphanumeric
identifier and a display name.  Run the `show' command without arguments
to list all suppliers.
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
  c.desc 'List suppliers or show details'
  c.arg_name '[<id>...]'
  c.long_desc <<-EOS
  List all defined supplier identifiers (without arguments) or show
  details for each supplier <id>.
  EOS
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

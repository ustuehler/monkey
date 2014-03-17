desc 'Show the list of accounts or details for some'

# The following doesn't affect help output as of gli-2.9.0:
#arg_name 'account-ref', [:optional, :multiple]
arg_name '[<account-ref>...]'

long_desc <<EOS
Show the list of all bank accounts (without arguments) or details for one or
more accounts identified by <account-ref>.
EOS

account_formatter = lambda do |account|
  <<-EOS
* account #{account.number}
  Bank: #{account.bank.code} (#{account.bank.name})
  Name: #{account.name}
  Alias: #{account.alias}
  EOS
end

command :show do |c|
  c.action do |global_options, options, args|
    if args.size == 0
      Monkey::Banking::Account.all.each do |account|
        puts account.alias || account.number
      end
    else
      args.each do |account_ref|
        result = Monkey::Banking::Account.all(:number => account_ref)
        result = Monkey::Banking::Account.all(:alias => account_ref) if result.size != 1
        exit_now!("bad account reference: #{account_ref}") if result.size != 1
        account = result.first

        puts account_formatter.call(account)
      end
    end
  end
end

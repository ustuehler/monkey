desc 'Show the list of banks or details for some'

# The following doesn't affect help output as of gli-2.9.0:
#arg_name 'id', [:optional, :multiple]
arg_name '[<id>...]'

long_desc <<EOS
Show the list of all banks (without arguments) or details for one or
more banks identified by <id>.
EOS

bank_formatter = lambda do |bank|
  <<-EOS
* bank #{bank.id}
  Name: #{bank.name}
  Number of accounts: #{bank.accounts.size}
  EOS
end

command :show do |c|
  c.action do |global_options, options, args|
    if args.size == 0
      Monkey::Banking::Bank.all.each do |bank|
        puts bank.id
      end
    else
      args.each do |bank_id|
        bank = Monkey::Banking::Bank.get!(bank_id)
        puts bank_formatter.call(bank)
      end
    end
  end
end

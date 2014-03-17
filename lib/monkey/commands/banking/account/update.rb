desc 'Update an existing account definition'

arg_name '<account-ref>'

long_desc <<EOS
Update properties of an existing bank account.  The <account-ref> argument may
be either an account number or an account's unique alias name.  If you
specified an account by number, the --bank argument may be required to make it
unique.
EOS

command :update do |c|
  c.desc 'Bank identifier'
  c.flag :bank

  c.desc 'New alias name'
  c.flag :alias

  c.desc 'New account number'
  c.flag :number

  c.desc 'Name of account holder'
  c.flag :name

  c.action do |global_options, options, args|
    help_now!('too many arguments') if args.size > 1
    help_now!('missing account reference (<account-ref>)') if args.size == 0

    account_ref = args[0]

    numbers = Monkey::Banking::Account.all.map {|a| a.number}
    if numbers.include?(account_ref)
      search = {:number => account_ref}

      if options[:bank]
        bank = Monkey::Banking::Bank.get!(options[:bank])
        search[:bank_id] = bank.id
      end
    else
      search = {:alias => account_ref}
    end

    if (result = Monkey::Banking::Account.all(search)).empty?
      exit_now! "reference to non-existing account: #{account_ref}"
    elsif result.size > 1
      exit_now! "ambiguous account reference: #{account_ref}"
    end

    account = result.first
    account[:name] = options[:name] unless options[:name].nil?
    account[:alias] = options[:alias] unless options[:alias].nil?
    account[:number] = options[:number] unless options[:number].nil?
    account.save!
  end
end

desc 'Update bank properties'

arg_name '<id>'

long_desc <<EOS
Manage bank properties. Update one or more of the properties of the bank
identified by <id>.
EOS

command :update do |c|
  c.desc 'Display name'
  c.flag :name

  c.action do |global_options, options, args|
    help_now!('too many arguments') if args.size > 1
    help_now!('missing <id>') if args.size == 0

    bank_id = args[0]
    bank = Monkey::Banking::Bank.get!(bank_id)
    bank[:name] = options[:name] unless options[:name].nil?
    bank.save!
  end
end

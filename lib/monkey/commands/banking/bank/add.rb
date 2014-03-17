desc 'Add a new bank definition'

arg_name '<id>'

long_desc <<EOS
Add a new bank definition identified by a unique alphanumeric string <id> with
an optional display name as specified with the --name option.
EOS

command :add do |c|
  c.desc 'Display name'
  c.flag :name

  c.action do |global_options, options, args|
    help_now!('too many arguments') if args.size > 1
    help_now!('missing <id>') if args.size == 0

    bank_id = args[0]
    bank = Monkey::Banking::Bank.new :id => bank_id
    bank[:name] = options[:name] unless options[:name].nil?
    bank.save!
  end
end

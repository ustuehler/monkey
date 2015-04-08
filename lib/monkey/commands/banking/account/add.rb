desc 'Add a new bank account definition'

arg_name '<number>'

long_desc <<EOS
Add a new bank account definition identified by a bank identifier and account
number and an optional name such as "savings" or "business", for example.
EOS

command :add do |c|
  c.desc 'Bank identifier'
  c.flag :bank, :required => true

  c.desc 'Non-default account type (e.g., HBCI)'
  c.flag :type

  c.desc 'Account name'
  c.flag :name

  c.action do |global_options, options, args|
    help_now!('too many arguments') if args.size > 1
    help_now!('missing account number (<number>)') if args.size == 0

    number = args[0]
    bank_id = options[:bank]

    account_class = Monkey::Banking::Account.type(options[:type])
    bank = account_class.new(:bank_id => bank_id, :number => number)
    bank[:name] = options[:name] unless options[:name].nil?
    bank.save!
  end
end

desc 'Show the list of customer invoices in tabular form'

arg_name '[<customer>...]'

command :list do |c|
  c.action do |global_options, options, args|
    require 'terminal-table'

    if args.size == 0
      invoices = Monkey::Business::Invoice.all(:supplier_id => nil)
    else
      invoices = Monkey::Business::Invoice.select { |i|
        i.supplier_id.nil? and args.include?(i.customer_id)
      }
    end

    table = Terminal::Table.new do |t|
      t << ['customer_id', 'number', 'date', 'amount', 'balance', 'status']
      t << :separator

      invoices.each do |i|
        status = []
        status << (i.closed? ? 'closed' : 'open')
        status << (i.paid? ? 'paid' : 'unpaid')
        status = status.join('/')

        t << [i.customer_id, i.number, i.date, i.amount, i.balance, status]
      end
    end

    # Set right-alignment for the 'amount' and 'balance' columns.
    (3..4).each { |col| table.align_column col, :right }

    puts table
  end
end

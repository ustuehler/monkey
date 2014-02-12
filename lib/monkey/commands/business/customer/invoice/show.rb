desc 'Show the list of customer invoices or details for some'

arg_name '[<number>...]'

invoice_formatter = lambda do |invoice|
  Terminal::Table.new(:title => invoice.number) do |t|
    t << ['Customer', {:value => "#{invoice.customer.name} (#{invoice.customer_id})", :colspan => 3}]
    t << ['Issue date', {:value => invoice.date, :colspan => 3}]
    t << ['Start date', {:value => invoice.start_date, :colspan => 3}]
    t << ['End date', {:value => invoice.end_date, :colspan => 3}]
    t << ['Amount total', {:value => invoice.amount, :colspan => 3}]
    t << ['Amount due', {:value => invoice.amount_due, :colspan => 3}]
    t << ['Amount paid', {:value => invoice.amount_paid, :colspan => 3}]
    t << :separator
    t << ['Qty', 'Unit', 'Unit Price', 'Description']
    t << :separator

    invoice.items.each do |item|
      t << [item.quantity, item.unit, item.unit_price, item.description]
    end
  end.to_s
end

command :show do |c|
  c.action do |global_options, options, args|
    require 'terminal-table'

    if args.size == 0
      Monkey::Business::Invoice.all(:supplier_id => nil).each do |i|
        puts i.number
      end
    else
      args.each do |number|
        i = Monkey::Business::Invoice.all(:supplier_id => nil,
                                          :number => number).first
        exit_now!("no such customer invoice: #{number}") unless i
        puts invoice_formatter.call(i)
      end
    end
  end
end

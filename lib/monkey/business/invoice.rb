require 'monkey/business'

module Monkey::Business

  # Outgoing invoice for my work at a customer
  class Invoice
    include Resource

    property :number, Integer, :key => true
    property :items, Csv

    belongs_to :customer

    # Get a ledger entry for this invoice.
    def entry
      customer.receivable_account.entries.find { |e| e.code == number.to_s }
    end

    # Get or create a ledger entry for this invoice.
    def entry!
      unless e = self.entry
        e = customer.receivable_account.add_entry amount, \
          customer.sales_account, amount_net,
          customer.tax_account, amount_tax
        e.description = customer.name
        e.code = number.to_s
        e.flag = '!'
      end
      e
    end

    def amount_net
      items.map { |i| i.unit_price * i.quantity }.reduce(:+)
    end

    def amount_tax
      amount_net * tax_rate
    end

    def tax_rate
      # FIXME: tax rate should be configurable
      '0.19'.to_d
    end

    def amount
      amount_net + amount_tax
    end

    def items
      super.map { |row| Item.new(*row) }
    end

    def items=(array)
      super(array.map { |row|
        raise ArgumentError, "expected: instance of #{Item.inspect}; " +
          "got: #{row.inspect}" unless row.is_a? Item
        row.to_a
      })
    end

    # Invoice item
    class Item
      attr_accessor :description, :quantity, :unit, :unit_price

      def initialize(description, quantity, unit, unit_price)
        @description, @quantity, @unit, @unit_price =
          description, quantity.to_i, unit, Money.parse(unit_price)
      end

      def to_a
        [@description, @quantity, @unit, @unit_price]
      end
    end
  end

end

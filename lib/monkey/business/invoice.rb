require 'monkey/business'

module Monkey::Business

  # Outgoing invoice for my work at a customer
  class Invoice
    include Resource

    belongs_to :customer, :key => true, :required => false
    belongs_to :supplier, :key => true, :required => false

    property :number, String, :key => true
    property :items, Csv

    # Get a ledger entry for this invoice.
    def entry
      primary_account = customer_or_supplier proc { |customer|
        customer.receivable_account
      }, proc { |supplier|
        supplier.payable_account
      }

      primary_account.entries.find { |e| e.code == number.to_s }
    end

    # Get or create a ledger entry for this invoice.
    def entry!
      first_account, second_account, tax_account, description =
        customer_or_supplier proc { |customer|
          [customer.receivable_account,
           customer.sales_account,
           customer.tax_account,
           customer.name]
        }, proc { |supplier|
          [supplier.payable_account,
           supplier.purchases_account,
           supplier.input_tax_account,
           supplier.name]
        }

      unless e = self.entry
        e = first_account.add_entry amount, \
          second_account, amount_net,
          tax_account, amount_tax
        e.description = description
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
          description, quantity.to_i, unit,
          Monkey::Accounting::Amount.coerce(unit_price)
      end

      def to_a
        [@description, @quantity, @unit, @unit_price]
      end
    end

    private

    def customer_or_supplier(customer_block, supplier_block)
      if customer_id and supplier_id
        raise "invoice has both a customer and supplier"
      elsif customer_id
        customer_block.call customer
      elsif supplier_id
        supplier_block.call supplier
      else
        raise "neither a customer nor a supplier for this invoice"
      end
    end

  end

end

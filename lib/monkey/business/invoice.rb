require 'monkey/business'

module Monkey::Business

  # Incoming supplier invoices and outgoing customer invoices.
  class Invoice
    include Resource

    belongs_to :customer, :key => true, :required => false
    belongs_to :supplier, :key => true, :required => false

    property :number, String, :key => true
    property :date, Date

    property :start_date, Date
    property :end_date, Date
    property :items, Csv

    # Return the largest customer invoice number in use.  The number
    # format must be such that numbers can be sorted alphanumerically.
    def self.last_number
      select { |i| !i.customer.nil? }.map { |i| i.number }.sort.last
    end

    # Return the next unused customer invoice number.  For this to
    # work, the number format must match "YYYYNNNN".
    def self.next_number
      if last_number =~ /^(\d{4})(\d{4})$/
        year, serial = $1, $2
        this_year = Time.now.strftime('%Y')

        if year == this_year
          "%s%04d" % [year, serial.to_i + 1]
        else
          "%s%04d" % [this_year, 1]
        end
      else
        raise "last invoice number doesn't match the pattern YYYYNNNN: #{last_number.inspect}"
      end
    end

    # Does this invoice have a payment entry?
    def paid?
      !payment_entry.nil?
    end

    # Return the customer or supplier account for this invoice.
    def business_account
      customer_or_supplier \
        proc { customer.receivable_account },
        proc { supplier.payable_account }
    end

    # Return the commodity account for this invoice.
    def commodity_account
      customer_or_supplier \
        proc { customer.sales_account },
        proc { supplier.purchases_account }
    end

    # Return the account to book taxes to for this invoice.
    def tax_account
      customer_or_supplier \
        proc { customer.tax_account },
        proc { supplier.input_tax_account }
    end

    # Get the ledger entry for this invoice.
    def entry
      business_account.entries.find { |e|
        e.code == number.to_s and e.accounts.include? commodity_account
      }
    end

    # Get the ledger entry for the payment of this invoice.
    def payment_entry
      business_account.entries.find { |e|
        e.code == number.to_s and not e.accounts.include? commodity_account
      }
    end

    # Get or create a ledger entry for this invoice.
    def entry!
      description = customer_or_supplier \
        proc { customer.name },
        proc { supplier.name }

      unless e = self.entry
        e = business_account.add_entry amount, \
          commodity_account, amount_net,
          tax_account, amount_tax
        e.date = date if date
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
      (super || []).map { |row| Item.new(*row) }
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
          description, quantity.to_f, unit,
          Monkey::Accounting::Amount.coerce(unit_price)
      end

      def to_a
        [@description, @quantity, @unit, @unit_price]
      end

      def ==(other)
        self.to_a == other.to_a
      end

      def map(*args, &block)
        to_a.map(*args, &block)
      end
    end

    private

    def customer_or_supplier(customer_block, supplier_block)
      if customer_id and supplier_id
        raise "invoice has both a customer and supplier"
      elsif customer_id
        customer_block.call
      elsif supplier_id
        supplier_block.call
      else
        raise "neither a customer nor a supplier for this invoice"
      end
    end

  end

end

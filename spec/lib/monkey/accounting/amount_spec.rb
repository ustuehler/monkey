# encoding:utf-8

require 'spec_helper'

module Monkey::Accounting

  describe Amount do
    {
      '$1' => {
        :commodity => '$',
        :quantity  => 1,
        :precision => 0
      },
      '£-50' => {
        :commodity => '£',
        :quantity  => -50,
        :precision => 0
      },
      '3.44 EUR' => {
        :commodity => 'EUR',
        :quantity  => 3.44,
        :precision => 2
      },
      'GOOG 500' => {
        :commodity => 'GOOG',
        :quantity  => 500,
        :precision => 0
      },
      '1.5h' => {
        :commodity => 'h',
        :quantity  => 1.5,
        :precision => 1
      },
      '90 apples' => {
        :commodity => 'apples',
        :quantity  => 90,
        :precision => 0
      },
      '0' => {
        :commodity => '',
        :quantity  => 0,
        :precision => 0
      },
      "CAD 9,000.00" => {
        :commodity => 'CAD',
        :quantity  => 9000,
        :precision => 2
      }
    }.each do |str, spec|
      it "parses #{str.inspect}" do
        amount = Amount.parse(str)
        amount.commodity.should == spec[:commodity]
        amount.quantity.to_s('F').should ==
          BigDecimal.new(spec[:quantity], 10).to_s('F')
        amount.precision.should == spec[:precision]
        amount.to_s.should == str
      end
    end

    it "can negate amounts" do
      a = Amount.parse('1 EUR')
      (-a).to_s.should == '-1 EUR'
    end

    it "can add amounts of same currency" do
      a = Amount.parse('1 EUR')
      b = Amount.parse('5.99 EUR')
      (a + b).to_s.should == '6.99 EUR'
    end

    it "can subtract amounts of same currency" do
      a = Amount.parse('1 EUR')
      b = Amount.parse('5.99 EUR')
      (a - b).to_s.should == '-4.99 EUR'
    end

  end

end

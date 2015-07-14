require 'spec_helper'

module Monkey::Banking

  describe Account do

    describe "#type" do
      it "returns the default account class for nil" do
        Account.type(nil).should == Account
      end

      it 'finds the "HBCI" account class (also "hbci" and :hbci)' do
        ["HBCI", 'hbci', :hbci].each do |name|
          Account.type(name).should == Account::HBCI
        end
      end

      it "raises an error for unknown types" do
        expect { Account.type(:foo) }.to raise_error(/foo/)
      end
    end

  end

end

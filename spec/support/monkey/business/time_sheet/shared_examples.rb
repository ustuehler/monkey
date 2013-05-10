# RSpec helper code for testing time sheets

shared_examples "a time sheet" do |params|

  describe "#clients" do
    subject { sheet.clients }

    it { should_not be_empty }
  end

  if params and params[:total]
    describe "#total" do
      subject { sheet.total }

      it { should be_within(0.01).of(params[:total]) }
    end
  end

  describe "#start_date" do
    subject { sheet.start_date }

    it { should <= sheet.end_date }
  end

  describe 'all records merged' do
    subject { sheet.records.inject({}) { |res, rec| res.merge!(rec) } }

    required_keys = [:date, :client, :time]
    optional_keys = [:notes]

    it "should have required keys #{required_keys.inspect}" do
      (subject.keys & required_keys).should =~ required_keys
    end

    it "should have no optional keys but #{optional_keys.inspect}" do
      (subject.keys - required_keys - optional_keys).should be_empty
    end
  end
end

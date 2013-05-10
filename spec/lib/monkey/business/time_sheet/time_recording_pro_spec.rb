require 'spec_helper'

module Monkey::Business

  describe TimeSheet::TimeRecordingPro do
    basedir = File.expand_path '../../../../../..', __FILE__
    datadir = "#{basedir}/examples/monkey-process-mail"

    subject(:time_sheet) {
      TimeSheet::TimeRecordingPro.load_file File.join(datadir, filename)
    }

    context "with report file timerec.20130301.20130331.e4.csv" do
      let(:filename) { "timerec.20130301.20130331.e4.csv" }

      it_behaves_like "a time sheet", :total => 118.87 do
        let(:sheet) { time_sheet }
      end

      describe "#clients" do
        subject { time_sheet.clients }

        it { should =~ ['client1', 'client2', 'example'] }
      end

      describe "#for_client(\"client1\")" do
        subject(:time_sheet_for_client) { time_sheet.for_client("client1") }

        it_behaves_like "a time sheet", :total => 80.35 do
          let(:sheet) { time_sheet_for_client }
        end

        describe "#clients" do
          subject { time_sheet_for_client.clients }

          it { should =~ ["client1"] }
        end

        describe "#between_dates" do
          it_behaves_like "a time sheet", :total => 72.12 do
            let(:sheet) {
              time_sheet_for_client.between_dates('2013-03-01', '2013-03-31')
            }
          end
        end
      end

      describe "#for_client(\"client2\")" do
        subject(:time_sheet_for_client) { time_sheet.for_client("client2") }

        it_behaves_like "a time sheet", :total => 13.4 do
          let(:sheet) { time_sheet_for_client }
        end
      end

      describe "#for_client(\"example\")" do
        subject(:time_sheet_for_client) { time_sheet.for_client("example") }

        it_behaves_like "a time sheet", :total => 25.12 do
          let(:sheet) { time_sheet_for_client }
        end
      end
    end
  end

end

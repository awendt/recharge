require 'rack/test'
require File.dirname(__FILE__) + '/spec_helper'

describe "Recharge" do

  before do
    # ugly hack to suppress warnings about 'already initialized constant DB'
    class Object ; remove_const :DB if const_defined?(:DB) ; end
    YAML.stub!(:load_file).and_return({
      "2011-01-06" => 'Heilige drei Könige',
      "2011-11-01" => 'Allerheiligen'
    })
  end

  describe "Homepage" do

    before { get '/' }

    it "responds" do
      last_response.should be_ok
    end

    it "renders a calendar" do
      last_response.should have_selector("table") do |year|
        year.should have_selector("tr##{Time.now.year}01") do |month|
          month.should have_selector("th", :content => "Jan")
          month.should have_selector("td##{Time.now.year}0101")
        end
        year.should have_selector("tr##{Time.now.year}02") do |month|
          month.should have_selector("td##{Time.now.year}0201")
        end
      end
    end

    it 'renders weekends and holidays by default' do
      last_response.should have_selector(".weekend")
      last_response.should have_selector(".holiday.active")
    end

    it 'labels the button "Save"' do
      last_response.should have_selector("button", :content => "Save")
    end
  end

  describe "connecting to CouchDB" do
    let(:couchdb) { mock(CouchRest::Database) }

    before do
      DB = couchdb
    end

    shared_examples_for "all updates" do
      it "advertises the response as JSON" do
        couchdb.should_receive(:save_doc).with(anything).and_return({'id' => 'some_id'})
        post @url, {
          :vacation => {'2011' => %w(20110101 20110102 20110303)},
          :holidays => {'2011' => %w(20110106)}
        }
        last_response.headers["Content-Type"].should == "application/json"
      end

      it "returns a redirect URL in JSON" do
        couchdb.should_receive(:save_doc).with(anything).and_return({'id' => 'some_id'})
        post @url, {
          :vacation => {'2011' => %w(20110101 20110102 20110303)},
          :holidays => {'2011' => %w(20110106)}
        }
        JSON.parse(last_response.body).should ==
            {"url" => "/cal/some_id"}
      end

      it 'halts on documents without vacation' do
        params = {:holidays => {'2011' => %w(20110106)}}
        couchdb.should_not_receive(:save_doc)
        post @url, params.merge(:vacation => {'2011' => []})
        post @url, params.merge(:vacation => {'2011' => ""})
      end
    end

    describe "saving" do

      before { @url = '/' }

      it_should_behave_like 'all updates'

      it "should put holidays and vacation days onto the Couch" do
        couchdb.should_receive(:save_doc).with({
          :vacation => {'2011' => %w(20110101)},
          :holidays => {"my" => "holidays"}
        }).and_return({})
        post @url, {:vacation => {'2011' => %w(20110101)}, :holidays => {:my => :holidays}}
      end
    end

    describe "serving a specific calendar" do
      before do
        couchdb.should_receive(:get).with('doc_id').and_return({
          'vacation' => {'2011' => %w(20110101 20110102)},
          'holidays' => {'2011' => %w(20110106)}
        })
        get '/cal/doc_id'
      end

      it "should pre-select vacation days" do
        last_response.should have_selector("#20110101.vacation")
        last_response.should have_selector("#20110102.vacation")
      end

      it 'changes the button label to "Update"' do
        last_response.should have_selector("button", :content => "Update")
      end

      describe "and marking holidays" do

        it "marks the active ones" do
          last_response.should have_selector("#20110106.holiday")
          last_response.should have_selector("#20110106.holiday.active")
        end

        it "skips the inactive ones" do
          last_response.should have_selector("#20111101.holiday")
          last_response.should_not have_selector("#20111101.holiday.active")
        end

      end
    end

    describe 'updating' do
      before do
        @url = '/cal/doc_id'
        couchdb.stub(:get).with('doc_id').and_return({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102)},
          'holidays' => {'2011' => %w(20110106)}
        })
      end

      it_should_behave_like 'all updates'

      it "should put holidays and vacation days onto the Couch" do
        couchdb.should_receive(:save_doc).with({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102 20110303)},
          'holidays' => {'2011' => %w(20110106)}
        }).and_return({})
        post @url, {
          :vacation => {'2011' => %w(20110101 20110102 20110303)},
          :holidays => {'2011' => %w(20110106)}
        }
      end
    end

    describe "exporting iCalendar" do
      before do
        couchdb.stub(:get).with('doc_id').and_return({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102)}
        })
      end

      it "advertises the response as iCal format" do
        get '/ics/doc_id'
        last_response.headers["Content-Type"].should =~ %r(text/calendar;)
      end

      it 'returns vacations in iCalendar format' do
        get '/ics/doc_id'
        last_response.body.should =~ /^BEGIN:VCALENDAR/
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20110102.+DTSTART:20110101.+SUMMARY:Vacation.+END:VEVENT/m
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20110103.+DTSTART:20110102.+SUMMARY:Vacation.+END:VEVENT/m
      end
    end

  end
end

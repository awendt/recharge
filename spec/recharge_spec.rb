require 'rack/test'
require File.dirname(__FILE__) + '/spec_helper'

describe "Recharge" do

  before do
    YAML.stub!(:load_file).and_return({
      "2011-01-06" => 'Heilige drei Könige',
      "2011-11-01" => 'Allerheiligen'
    })
  end

  describe "Homepage and years" do

    it 'does not render a link to iCalendar export' do
      get '/'
      last_response.should_not have_selector("a[href*='/ics/']")
    end

    it 'does not render a link to iCalendar export' do
      get '/2012'
      last_response.should_not have_selector("a[href*='/ics/']")
    end
  end

  describe "connecting to CouchDB" do
    let(:couchdb) { CouchRest::Database.any_instance }

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

    describe "saving specific year" do

      before { @url = '/2012' }

      it_should_behave_like 'all updates'

      it "should put holidays and vacation days onto the Couch" do
        couchdb.should_receive(:save_doc).with({
          :vacation => {'2012' => %w(20120101)},
          :holidays => {"my" => "holidays"}
        }).and_return({})
        post @url, {:vacation => {'2012' => %w(20120101)}, :holidays => {:my => :holidays}}
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

      it 'does not overwrite but merges the result' do
        couchdb.should_receive(:save_doc).with({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102), '2012' => %w(20120101)},
          'holidays' => {'2011' => %w(20110106), '2012' => %w(20120106)}
        }).and_return({})
        post @url, {
          :vacation => {'2012' => %w(20120101)},
          :holidays => {'2012' => %w(20120106)}
        }
      end
    end

    describe "exporting iCalendar" do
      before do
        couchdb.stub(:get).with('doc_id').and_return({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102 20110104), '2012' => %w(20120102)}
        })
      end

      it "advertises the response as iCal format" do
        get '/ics/doc_id'
        last_response.headers["Content-Type"].should =~ %r(text/calendar;)
      end

      it 'groups vacations in ranges' do
        get '/ics/doc_id'
        last_response.body.should =~ /^BEGIN:VCALENDAR/
        last_response.body.scan(/BEGIN:VEVENT/).should have(3).items
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20110103.+DTSTART:20110101.+SUMMARY:Vacation.+END:VEVENT/m
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20110105.+DTSTART:20110104.+SUMMARY:Vacation.+END:VEVENT/m
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20120103.+DTSTART:20120102.+SUMMARY:Vacation.+END:VEVENT/m
      end

      it 'assigns a display name for the calendar' do
        get '/ics/doc_id'
        last_response.body.should =~ /X-WR-CALNAME:Vacation/m
      end
    end

  end
end

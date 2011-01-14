require 'rack/test'
require File.dirname(__FILE__) + '/spec_helper'

describe "GoneFishing" do

  before do
    # ugly hack to suppress warnings about 'already initialized constant DB'
    class Object ; remove_const :DB if const_defined?(:DB) ; end
  end

  describe "Homepage" do

    it "should respond" do
      get '/'
      last_response.should be_ok
    end

    it "should render a calendar" do
      get '/'
      last_response.should have_selector("table")
      last_response.should have_selector("tr##{Time.now.year}01")
      last_response.should have_selector("td##{Time.now.year}0101")
      last_response.should have_selector(".weekend")
    end

  end

  describe "connecting to CouchDB" do
    let(:couchdb) { mock(CouchRest::Database) }

    before do
      DB = couchdb
    end

    describe "saving vacation days" do

      it "should put the days onto the Couch" do
        couchdb.should_receive(:save_doc).with({"my" => "days"}).and_return({})
        post '/', {:vacation_days => {:my => :days}}
      end

      it "should advertise the response as JSON" do
        couchdb.should_receive(:save_doc).with(anything).and_return({'id' => 'some_id'})
        post '/', {:vacation_days => {:my => :days}}
        last_response.headers["Content-Type"].should == "application/json"
      end

      it "should send a redirect URL in JSON" do
        couchdb.should_receive(:save_doc).with(anything).and_return({'id' => 'some_id'})
        post '/', {:vacation_days => {:my => :days}}
        JSON.parse(last_response.body).should ==
            {"url" => "/some_id"}
      end
    end

    describe "serving a specific calendar" do
      it "should pre-select vacation days" do
        couchdb.should_receive(:get).with('saved_calendar').and_return({'2011' => %w(20110101 20110102)})
        get '/saved_calendar'
        last_response.should have_selector("#20110101.vacation")
        last_response.should have_selector("#20110102.vacation")
      end
    end
  end
end

require 'rack/test'
require File.dirname(__FILE__) + '/spec_helper'

describe "GoneFishing" do

  before do
    # ugly hack to suppress warnings about 'already initialized constant DB'
    class Object ; remove_const :DB if const_defined?(:DB) ; end
    YAML.stub!(:load_file)
  end

  describe "Homepage" do

    it "should respond" do
      get '/'
      last_response.should be_ok
    end

    it "should render a calendar" do
      get '/'
      last_response.should have_selector("table") do |year|
        year.should have_selector("tr##{Time.now.year}01") do |month|
          month.should have_selector("th", :content => "Jan")
          month.should have_selector("td##{Time.now.year}0101")
        end
        year.should have_selector("tr##{Time.now.year}02") do |month|
          month.should have_selector("td##{Time.now.year}0201")
        end
      end
      last_response.should have_selector(".weekend")
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
        post @url, {:vacation_days => {'2011' => %w(20110101 20110102 20110303)}}
        last_response.headers["Content-Type"].should == "application/json"
      end

      it "returns a redirect URL in JSON" do
        couchdb.should_receive(:save_doc).with(anything).and_return({'id' => 'some_id'})
        post @url, {:vacation_days => {'2011' => %w(20110101 20110102 20110303)}}
        JSON.parse(last_response.body).should ==
            {"url" => "/some_id"}
      end
    end

    describe "saving vacation days" do

      before { @url = '/' }

      it_should_behave_like 'all updates'

      it "should put the days onto the Couch" do
        couchdb.should_receive(:save_doc).with({"my" => "days"}).and_return({})
        post '/', {:vacation_days => {:my => :days}}
      end
    end

    describe "serving a specific calendar" do
      it "should pre-select vacation days" do
        pending 'currently done by JS'
        couchdb.should_receive(:get).with('doc_id').and_return({'2011' => %w(20110101 20110102)})
        get '/doc_id'
        last_response.should have_selector("#20110101.vacation")
        last_response.should have_selector("#20110102.vacation")
      end
    end

    describe 'updating vacation days' do
      before do
        @url = '/doc_id'
        couchdb.stub(:get).with('doc_id').and_return({
          '_id' => 'doc_id',
          '2011' => %w(20110101 20110102)
        })
      end

      it_should_behave_like 'all updates'

      it 'should put the days onto the couch' do
        couchdb.should_receive(:save_doc).with({
          '_id' => 'doc_id',
          '2011' => %w(20110101 20110102 20110303)
        }).and_return({})
        post '/doc_id', {:vacation_days => {'2011' => %w(20110101 20110102 20110303)}}
      end
    end
  end
end

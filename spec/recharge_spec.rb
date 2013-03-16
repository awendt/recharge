require 'rack/test'
require File.dirname(__FILE__) + '/spec_helper'

describe "Recharge" do

  it 'gzips responses' do
    get '/', {}, {'HTTP_ACCEPT_ENCODING' => 'gzip'}
    last_response.headers['Content-Encoding'].should =~ /gzip/
  end

  describe 'indexing by robots' do

    it 'welcomes Googlebot on the hompage' do
      get '/'
      last_response.should_not have_selector("meta[name=robots]")
    end

    it 'tells Googlebot to bugger off on other years' do
      get '/2011'
      last_response.should have_selector("meta[name=robots]")
      last_response.should have_selector("meta[content=noindex]")
    end

    it 'tells Googlebot to bugger off on saved calendars' do
      CouchRest::Database.any_instance.should_receive(:get).and_return(mock.as_null_object)
      get '/cal/my_cal'
      last_response.should have_selector("meta[name=robots]")
      last_response.should have_selector("meta[content=noindex]")
    end

  end

  describe "Homepage and years" do

    it 'does not render a link to iCalendar export' do
      get '/'
      last_response.should_not have_selector("a[href*='/ics/']")
    end

    it 'includes a Cache-Control header in the response' do
      get '/'
      last_response['Cache-Control'].should =~ /public/
      last_response['Cache-Control'].should =~ /must-revalidate/
      last_response['Cache-Control'].should =~ /max-age=300/
      last_response['Expires'].should_not be_empty
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
        last_response["Content-Type"].should =~ %r(application/json)
      end
    end

    shared_examples_for "all vacation updates" do
      it "returns a redirect URL in JSON" do
        couchdb.should_receive(:save_doc).with(anything).and_return({'id' => 'some_id'})
        post @url, {
          :vacation => {'2011' => %w(20110101 20110102 20110303)},
          :holidays => {'2011' => %w(20110106)}
        }
        JSON.parse(last_response.body)["url"].should =~ %r(^/cal/some_id)
      end

      it 'halts on documents without vacation' do
        params = {:holidays => {'2011' => %w(20110106)}}
        couchdb.should_not_receive(:save_doc)
        post @url, params.merge(:vacation => {'2011' => []})
        post @url, params.merge(:vacation => {'2011' => ""})
      end
    end

    describe 'caching via HTTP' do
      it 'should be supported through ETags' do
        doc = CouchRest::Document.new
        doc['vacation'] = doc['holidays'] = {}
        doc['_rev'] = '15-xyz'
        couchdb.stub(:get).with('doc_id').and_return(doc)

        get '/cal/doc_id'
        last_response['ETag'].should == '"15-xyz"'
      end
    end

    describe "saving" do

      before { @url = '/' }

      it_should_behave_like 'all updates'
      it_should_behave_like 'all vacation updates'

      it "should put holidays and vacation days onto the Couch" do
        couchdb.should_receive(:save_doc).with({
          :vacation => {'2011' => %w(20110101)},
          :half => {'2011' => %w(20110101)},
          :holidays => {"my" => "holidays"}
        }).and_return({})
        post @url, {
          vacation: {'2011' => %w(20110101)},
          half: {'2011' => %w(20110101)},
          holidays: {:my => :holidays}
        }
      end
    end

    describe "saving specific year" do

      before { @url = '/2012' }

      it_should_behave_like 'all updates'
      it_should_behave_like 'all vacation updates'

      it "should put holidays and vacation days onto the Couch" do
        couchdb.should_receive(:save_doc).with({
          :vacation => {'2012' => %w(20120101)},
          :half => {'2012' => %w(20120101)},
          :holidays => {"my" => "holidays"}
        }).and_return({})
        post @url, {
          vacation: {'2012' => %w(20120101)},
          half: {'2012' => %w(20120101)},
          holidays: {:my => :holidays}}
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
      it_should_behave_like 'all vacation updates'

      it "should put holidays and vacation days onto the Couch" do
        couchdb.should_receive(:save_doc).with({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102 20110303)},
          'half' => {'2011' => %w(20110101 20110102)},
          'holidays' => {'2011' => %w(20110106)}
        }).and_return({})
        post @url, {
          :vacation => {'2011' => %w(20110101 20110102 20110303)},
          :half => {'2011' => %w(20110101 20110102)},
          :holidays => {'2011' => %w(20110106)}
        }
      end

      it 'does not overwrite but merges the result' do
        couchdb.should_receive(:save_doc).with({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102), '2012' => %w(20120101)},
          'half' => {'2012' => %w(20120101)},
          'holidays' => {'2011' => %w(20110106), '2012' => %w(20120106)}
        }).and_return({})
        post @url, {
          :vacation => {'2012' => %w(20120101)},
          :half => {'2012' => %w(20120101)},
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
        last_response["Content-Type"].should =~ %r(text/calendar;)
      end

      it 'groups vacations in ranges' do
        get '/ics/doc_id'
        last_response.body.should =~ /^BEGIN:VCALENDAR/
        last_response.body.scan(/BEGIN:VEVENT/).should have(3).items
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20110103.+DTSTART:20110101.+SUMMARY:Recharge.+END:VEVENT/m
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20110105.+DTSTART:20110104.+SUMMARY:Recharge.+END:VEVENT/m
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20120103.+DTSTART:20120102.+SUMMARY:Recharge.+END:VEVENT/m
      end

      it 'assigns a default display name for the calendar' do
        get '/ics/doc_id'
        last_response.body.should =~ /X-WR-CALNAME:Recharge/m
      end

      it 'assigns the name of the calendar if given' do
        couchdb.stub(:get).with('doc_id').and_return({
          '_id' => 'doc_id',
          'name' => 'My calendar',
          'vacation' => {'2011' => %w(20110101 20110102 20110104), '2012' => %w(20120102)}
        })
        get '/ics/doc_id'
        last_response.body.should =~ /X-WR-CALNAME:My calendar/m
        last_response.body.should =~
            /BEGIN:VEVENT.+DTEND:20110103.+DTSTART:20110101.+SUMMARY:My calendar.+END:VEVENT/m
      end
    end

    describe 'renaming' do
      before do
        @url = '/cal/doc_id/name'
        couchdb.stub(:get).with('doc_id').and_return({
          '_id' => 'doc_id',
          'vacation' => {'2011' => %w(20110101 20110102)},
          'holidays' => {'2011' => %w(20110106)}
        })
      end

      it_should_behave_like 'all updates'

      it 'sets the name property' do
        couchdb.should_receive(:save_doc).with(
            hash_including({'name' => 'Urlaubskalender'})).and_return({'id' => 'doc_id'})
        put @url, {name: 'Urlaubskalender'}
      end

      it 'returns the name for the view' do
        couchdb.stub(:save_doc).and_return({'id' => 'saved_doc_id'})
        couchdb.stub(:get).with('saved_doc_id').and_return({'name' => 'saved_name'})
        put @url, {name: 'Urlaubskalender'}
        JSON.parse(last_response.body)["name"].should == 'saved_name'
      end
    end

  end

  describe 'holidays' do
    it "advertises the response as JSON" do
      get '/holidays/de_by/2011'
      last_response["Content-Type"].should =~ %r(application/json)
    end

    it "supports HTTP caching by sending an ETag" do
      get '/holidays/de_by/2011'
      last_response['ETag'].should == '"de_by-2011"'
    end

    it 'returns a hash of holidays in the given region' do
      get '/holidays/de_by/2011'
      JSON.parse(last_response.body).should be_a(Hash)
      JSON.parse(last_response.body)['20110101'].should == 'Neujahrstag'
    end

    it 'returns 404 if no such region' do
      get '/holidays/de_xx/2011'
      last_response.status.should == 404
    end

    it 'returns 200 if no such year (to_i returns 0 for invalid numbers)' do
      get '/holidays/de_by/xxx'
      last_response.status.should == 200
    end
  end

end

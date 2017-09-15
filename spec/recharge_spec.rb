require 'rack/test'
require File.dirname(__FILE__) + '/spec_helper'

describe "Recharge" do

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

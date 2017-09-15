require 'spec_helper'

describe "Content delivery" do

  subject { last_response }

  context 'when accepting gzip' do
    before do
      get '/', {}, {'HTTP_ACCEPT_ENCODING' => 'gzip'}
    end

    its(['Content-Encoding']) { is_expected.to match /gzip/ }
  end

  context 'when doing a standard GET' do

    before { get '/' }

    its(['Cache-Control']) { is_expected.to match /public/ }
    its(['Cache-Control']) { is_expected.to match /must-revalidate/ }
    its(['Cache-Control']) { is_expected.to match /max-age=300/ }
    its(['Expires']) { is_expected.to_not be_empty }

  end

  context 'when requesting a calendar' do

    before do
      # TODO: Use factory that wraps CouchRest::Document.new here
      doc = double(rev: '15-xyz').as_null_object
      allow_any_instance_of(CouchRest::Database).to receive(:get).with('doc_id').and_return(doc)

      get '/cal/doc_id'
    end

    its(['ETag']) { is_expected.to eq('"15-xyz"') }

  end

end
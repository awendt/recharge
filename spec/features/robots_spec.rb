require 'spec_helper'

describe "Recharge", type: :feature do

  describe 'indexing by robots' do

    it 'welcomes Googlebot on the hompage' do
      visit '/'

      expect(page).to_not have_selector("meta[name=robots]", visible: false)
    end

    it 'tells Googlebot to bugger off on other years' do
      visit '/2011'

      expect(page).to have_selector("meta[name=robots]", visible: false)
      expect(page).to have_selector("meta[content=noindex]", visible: false)
    end

    it 'tells Googlebot to bugger off on saved calendars' do
      allow_any_instance_of(CouchRest::Database).to receive(:get).and_return(double.as_null_object)
      visit '/cal/my_cal'

      expect(page).to have_selector("meta[name=robots]", visible: false)
      expect(page).to have_selector("meta[content=noindex]", visible: false)
    end

  end

end

require 'spec_helper'

describe "Recharge", type: :feature do

  context 'when on the homepage' do

    before { visit '/' }

    it 'does not render a link to iCalendar export on the homepage' do
      expect(page).to_not have_content('Kalenderadresse kopieren')
    end

  end

  context 'when in another year' do

    before { visit '/2015' }

    it 'does not render a link to iCalendar export on the homepage' do
      expect(page).to_not have_content('Kalenderadresse kopieren')
    end

  end

  context 'when on a saved calendar' do

    before do
      allow_any_instance_of(CouchRest::Database).to receive(:get).and_return(double.as_null_object)
      visit '/cal/123'
    end

    it 'renders a link to iCalendar export on the homepage' do
      expect(page).to have_content('Kalenderadresse kopieren')
    end

  end

end

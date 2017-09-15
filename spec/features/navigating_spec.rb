require 'spec_helper'

shared_examples_for "showing a calendar" do

  it 'shows the right year' do
    expect(page.first("tr")['id']).to eq "#{year}01"

    # when New Year's is on a week, we don't show it
    expect("#{year}0101".."#{year}0103").to cover(page.first("td")['id'])
  end

  it 'links to the next year' do
    expect(page).to have_selector('a#next', text: year + 1)
  end

  it 'links to the previous year' do
    expect(page).to have_selector('a#previous', text: year - 1)
  end

  it 'shows no vacation days' do
    expect(page).to_not have_selector('.vacation')
  end
end

describe "Calendar", type: :feature do

  before { visit '/' }

  it_behaves_like "showing a calendar" do
    let(:year) { Time.now.year }
  end

  context 'when going to next year' do

    before do
      click_link('next')
    end

    it_behaves_like "showing a calendar" do
      let(:year) { Time.now.year + 1 }
    end

  end

  context 'when going to previous year' do

    before do
      click_link('previous')
    end

    it_behaves_like "showing a calendar" do
      let(:year) { Time.now.year - 1 }
    end

  end

end

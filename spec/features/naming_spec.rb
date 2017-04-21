require 'spec_helper'

feature 'User changes the name on her calendar' do
  scenario 'default name on blank calendar' do
    visit "/"

    expect(page).to have_selector('h1', text: 'Recharge')
    expect(page.title).to match(/Recharge/)
  end

  scenario 'heading and title are updated', js: true do
    visit '/2017'

    select_vacation('20170109', '20170113')
    save_calendar

    expect(page).to have_selector('h1', text: 'Mein Kalender')
    expect(page.title).to match(/Mein Kalender/)

    page.find_by_id('title').click
    page.find('div.editable-input input').set('Mein toller Kalender')
    page.find('.editable-submit').click

    expect(page).to have_selector('h1', text: 'Mein toller Kalender')
    expect(page.title).to match(/Mein toller Kalender/)
  end
end
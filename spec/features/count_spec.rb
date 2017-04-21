require 'spec_helper'

feature 'User sees the count being updated' do

  scenario 'on blank calendar', js: true do
    visit "/2011"

    expect(page).to have_selector('#count', text: '0')
  end

  scenario 'with some days selected', js: true do
    visit "/2011"
    select_vacation('20110110', '20110114')

    expect(page).to have_selector('#count', text: '5')
  end

  scenario 'when saving the calendar', js: true do
    visit "/2011"
    select_vacation('20110110', '20110112')
    save_calendar

    expect(page).to have_selector('#count', text: '3')
  end

  scenario 'when navigating years', js: true do
    visit "/2011"
    select_vacation('20110110', '20110114')
    save_calendar
    expect(page).to have_selector('#count', text: '5')

    click_link('2012')
    expect(page).to have_selector('#count', text: '0')

    click_link('2011')
    expect(page).to have_selector('#count', text: '5')
  end

  scenario 'when selecting different vacations in different years', js: true do
    visit "/2011"
    select_vacation('20110110', '20110114')
    save_calendar
    expect(page).to have_selector('#count', text: '5')

    click_link('2012')
    expect(page).to have_selector('#count', text: '0')

    select_vacation('20120312', '20120315')
    save_calendar
    expect(page).to have_selector('#count', text: '4')

    click_link('2011')
    expect(page).to have_selector('#count', text: '5')
  end

  scenario 'when updating a calendar', js: true do
    visit '/2017'

    select_vacation('20170109', '20170113')
    save_calendar
    expect(page).to have_selector('#count', text: '5')

    select_vacation('20170109', '20170110')
    save_calendar
    expect(page).to have_selector('#count', text: '4')
  end

  scenario 'with half days', js: true do
    visit "/2012"
    select_vacation('20120116', '20120120')
    expect(page).to have_selector('#count', text: '5') # 5 full days

    select_vacation('20120119', '20120120')
    expect(page).to have_selector('#count', text: '4') # last 2 days count half

    select_vacation('20120119', '20120120')
    expect(page).to have_selector('#count', text: '3') # last 2 days are not vacation

    select_vacation('20120119', '20120120')
    expect(page).to have_selector('#count', text: '5') # 5 full days
  end

end
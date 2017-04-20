Then /^I should not see vacation days$/ do
  expect(page).to_not have_selector('.vacation')
end

Then /^I should see a big fat "([^"]*)" as vacation day count$/ do |count|
  expect(page).to have_css('#count', text: count)
end

When /^I (de-)?select vacation from "([^"]*)" to "([^"]*)"$/ do |ignored, from, to|
  (from..to).to_a.each do |id|
    page.find_by_id(id).click
  end
end

When /^I (de-)?select vacation on "([^"]*)"$/ do |ignored, date|
  page.find_by_id(date).click
end

Then /^I should see vacation days from "([^"]*)" to "([^"]*)"$/ do |from, to|
  days = (from..to)
  # days.size returns nil since the range items are not numeric
  expect(days.to_a.size).to be >= 1

  days.each do |id|
    expect(page).to have_selector(".vacation[id='#{id}']", count: 1)
  end
end

Then /^I should see a vacation day on "([^"]*)"$/ do |date|
  expect(page).to have_selector(".vacation[id='#{date}']", count: 1)
end

When /^I mark vacation days on "([^"]*)" and "([^"]*)" as half$/ do |day1, day2|
  page.find_by_id("halfdays").click
  sleep 2
  page.find_by_id(day1).click
  page.find_by_id(day2).click
end
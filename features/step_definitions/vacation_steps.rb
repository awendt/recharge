Then /^I should not see vacation days$/ do
  page.all(".vacation").should be_empty
end

Then /^I should see a big fat "([^"]*)" as vacation day count$/ do |count|
  page.find_by_id('count').text.should == count
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
  days.should have_at_least(1).item

  days.each do |id|
    page.should have_selector("##{id}.vacation", count: 1)
  end
end

Then /^I should see a vacation day on "([^"]*)"$/ do |date|
  page.should have_selector("##{date}.vacation", count: 1)
end

When /^I mark vacation days on "([^"]*)" and "([^"]*)" as half$/ do |day1, day2|
  page.find_by_id("halfdays").click
  sleep 2
  page.find_by_id(day1).click
  page.find_by_id(day2).click
end
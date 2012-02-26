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
  days = (from..to).to_a
  days.should have_at_least(1).item

  page.should have_selector('.vacation', :count => days.count)
  days.each do |id|
    page.find_by_id(id)['class'].split.should include('vacation')
  end
end

Then /^I should see a vacation day on "([^"]*)"$/ do |date|
  page.find_by_id(date)['class'].split.should include('vacation')
end

Then /^I should see links for next and previous year$/ do
  next_year = Time.now.year + 1
  previous_year = Time.now.year - 1
  Then %Q(I should see "#{next_year}" within "a#next")
  And %Q(I should see "#{previous_year}" within "a#previous")
end

Then /^I should not see vacation days$/ do
  page.all(".vacation").should be_empty
end

When /^I follow (next|previous) year's link$/ do |direction|
  page.click_link(direction)
end

Then /^I should see a calendar for the (current|next|previous) year$/ do |relative_year|
  year = Time.now.year + case(relative_year)
  when 'next'
    1
  when 'previous'
    -1
  else
    0
  end
  page.first("tr")['id'].should == "#{year}01"
  ["#{year}0101", "#{year}0102", "#{year}0103"].should include(page.first("td")['id'])
  page.all('.monday').should_not be_empty
  page.all('.friday').should_not be_empty
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

  page.should have_css('.vacation', :count => days.count)
  days.each do |id|
    page.should have_css("##{id}.vacation", :count => 1)
  end
end

Then /^I should see "([^"]*)" active holidays$/ do |count|
  page.all('.holiday.active').size.should == count.to_i
end

When /^I toggle holiday on "([^"]*)"$/ do |day|
  page.execute_script(%Q!var e = $.Event("click"); e.shiftKey = true; $("##{day}").trigger(e);!)
end

Then /^"([^"]*)" should be an active holiday$/ do |date|
  page.find_by_id(date)['class'].split.should include('holiday', 'active')
end

Then /^I should see a vacation day on "([^"]*)"$/ do |date|
  page.find_by_id(date)['class'].split.should include('vacation')
end

Then /^"([^"]*)" should not be an active holiday$/ do |date|
  page.find_by_id(date)['class'].split.should include('holiday')
  page.find_by_id(date)['class'].split.should_not include('active')
end
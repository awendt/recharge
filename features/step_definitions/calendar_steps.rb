Then /^I should see links for next and previous year$/ do
  next_year = Time.now.year + 1
  previous_year = Time.now.year - 1
  Then %Q(I should see "#{next_year}" within "a#next")
  And %Q(I should see "#{previous_year}" within "a#previous")
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

When /^I switch to region "([^"]*)"$/ do |region|
  select(region, :from => 'region')
end

Then /^I should not see a popover$/ do
  page.should_not have_selector('.popover')
end

Then /^I should see "([^"]*)" in a popover$/ do |text|
  page.should have_selector('.popover')
  page.find('.popover').text.should =~ %r(#{text})
end

When /^I save the calendar$/ do
  page.find_by_id("save").click
end

When /^I rename the calendar to "([^"]*)"$/ do |new_name|
  page.find_by_id("rename").click
  fill_in('name', with: new_name)
  page.find_by_id('save_rename').click
end
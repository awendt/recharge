When /^I follow (next|previous) year's link$/ do |direction|
  page.click_link(direction)
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

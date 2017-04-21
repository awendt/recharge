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

When /^I rename the calendar to "([^"]*)"$/ do |new_name|
  page.find_by_id('title').click
  page.find('div.editable-input input').set(new_name)
  page.find('.editable-submit').click
end

Then /^I should see "([^"]*)" as document title$/ do |title|
  expect(page).to have_title(title)
end
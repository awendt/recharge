Then /^I should see ([^"]*) active holidays$/ do |count|
  page.should have_selector('.holiday.active')
  page.all('.holiday.active').size.should == count.to_i
end

When /^I toggle holiday on "([^"]*)"$/ do |day|
  page.execute_script(%Q!var e = $.Event("click"); e.shiftKey = true; $("##{day}").trigger(e);!)
end

Then /^"([^"]*)" should be an active holiday$/ do |date|
  page.find_by_id(date)['class'].split.should include('holiday', 'active')
end

Then /^"([^"]*)" should not be an active holiday$/ do |date|
  page.find_by_id(date)['class'].split.should include('holiday')
  page.find_by_id(date)['class'].split.should_not include('active')
end

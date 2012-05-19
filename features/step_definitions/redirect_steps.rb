When /^I visit the homepage coming from the old site$/ do
  visit '/#moved'
end

Then /^I should be able to bookmark the site without any URL clutter$/ do
  page.evaluate_script('window.location.hash').should be_empty
end
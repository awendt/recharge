def select_vacation(from, to=nil)
  range = to ? (from..to) : (from..from)
  range.each do |date|
    page.find_by_id(date).click
  end
end

def save_calendar
  page.find_by_id('save').click
end

events = @events
cal = Icalendar::Calendar.new
events.each do |event|
  cal.event do |e|
    e.description = event.display_name.localize
    e.dtstart      = Icalendar::Values::DateTime.new(event.start_at)
    e.dtend        = Icalendar::Values::DateTime.new(event.end_at)
    e.location     = event.library.address
  end
end
cal.publish
cal.to_ical

checkouts = @checkouts
cal = Icalendar::Calendar.new
checkouts.each do |checkout|
  cal.event do |e|
    e.summary     = I18n.t('activerecord.attributes.checkout.due_date')
    e.description = checkout.item.manifestation.original_title
    e.dtstart     = Icalendar::Values::Date.new(checkout.due_date.to_date)
    e.dtend       = Icalendar::Values::Date.new(checkout.due_date.to_date)
    e.location    = checkout.item.shelf.library.display_name.localize
  end
end
cal.publish
cal.to_ical

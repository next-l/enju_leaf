json.array!(@events) do |event|
  json.extract! event, :id
  json.title event.display_name.localize
  if event.all_day
    json.start event.start_at.iso8601
    json.end event.end_at.tomorrow.beginning_of_day.iso8601
    json.allDay event.all_day
  else
    json.start event.start_at.iso8601
    json.end event.end_at.iso8601
  end
  json.url event_url(event)
end

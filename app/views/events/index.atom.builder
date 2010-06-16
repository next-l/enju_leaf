atom_feed(:url => events_url(:format => :atom)) do |feed|
  feed.title t('event.library_group_event', :library_group_name => @library_group.display_name.localize)
  feed.updated(@events.first ? @events.first.created_at : Time.zone.now)

  @events.each do |event|
    feed.entry(event) do |entry|
      entry.title(event.title)
    end
  end
end

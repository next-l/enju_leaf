atom_feed(url: agents_url(format: :atom)) do |feed|
  feed.title t('agent.library_group_agent', library_group_name: @library_group.display_name.localize)
  feed.updated(@agents.first ? @agents.first.created_at : Time.zone.now)

  @agents.each do |agent|
    feed.entry(agent) do |entry|
      entry.title(agent.full_name)
    end
  end
end

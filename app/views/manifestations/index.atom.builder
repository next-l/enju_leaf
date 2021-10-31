atom_feed(url: manifestations_url(format: :atom)) do |feed|
  feed.title t('manifestation.query_search_result', query: @query, library_group_name: @library_group.display_name.localize)
  feed.updated(@manifestations.first ? @manifestations.first.created_at : Time.zone.now)

  @manifestations.each do |manifestation|
    feed.entry(manifestation) do |entry|
      entry.title(manifestation.original_title)
      if defined?(EnjuBookmark)
        entry.content(manifestation.tags.join(' '), type: 'html')
      end

      manifestation.creators.readable_by(current_user).each do |agent|
        entry.author do |author|
          author.name(agent.full_name)
        end
      end
    end
  end
end

atom_feed(url: manifestations_url(format: :atom),
  "xmlns:opds" => "http://opds-spec.org/2010/catalog",
  "xmlns:jepa" => "http://www.jepa.or.jp/xmlns/atomPhonetics/1.1"
) do |feed|
  feed.title t('manifestation.query_search_result', query: @query, library_group_name: @library_group.display_name.localize)
  feed.updated(@manifestations.first ? @manifestations.first.created_at : Time.zone.now)
  feed.link rel: 'start', href: manifestations_url(format: :opds), type: "application/atom+xml;profile=opds-catalog;kind=navigation"

  @manifestations.each do |manifestation|
    feed.entry(manifestation) do |entry|
      entry.link rel: "http://opds-spec.org/acquisition/borrow", href: manifestation_url(manifestation), type: 'text/html'
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

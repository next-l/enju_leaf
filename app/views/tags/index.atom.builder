atom_feed(:url => tags_url(:format => :atom)) do |feed|
  feed.title t('page.listing', :model => t('activerecord.models.tag')) + " (#{@library_group.display_name.localize})"
  feed.updated(@tags.first ? @tags.first.created_at : Time.zone.now)

  for tag in @tags
    feed.entry(tag) do |entry|
      entry.title(tag.name)
    end
  end
end

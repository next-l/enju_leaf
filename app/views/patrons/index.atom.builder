atom_feed(:url => patrons_url(:format => :atom)) do |feed|
  feed.title t('patron.library_group_patron', :library_group_name => @library_group.display_name.localize)
  feed.updated(@patrons.first ? @patrons.first.created_at : Time.zone.now)

  for patron in @patrons
    feed.entry(patron) do |entry|
      entry.title(patron.full_name)

    end
  end
end

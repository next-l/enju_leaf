atom_feed(:url => subjects_url(:format => :atom)) do |feed|
  feed.title t('page.listing', :model => t('activerecord.models.subject')) + " (#{@library_group.display_name.localize})"
  feed.updated(@subjects.first ? @subjects.first.created_at : Time.zone.now)

  @subjects.each do |subject|
    feed.entry(subject) do |entry|
      entry.title(subject.term)
    end
  end
end

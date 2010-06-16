atom_feed(:url => reserves_url(:format => :atom)) do |feed|
  if @user
    feed.title t('reserve.user_reserve', :login_name => @user.username)
  else
    feed.title t('reserve.library_group_reserve', :library_group_name => @library_group.display_name.localize)
  end
  feed.updated(@reserves.first ? @reserves.first.created_at : Time.zone.now)

  @reserves.each do |reserve|
    feed.entry(reserve) do |entry|
      entry.title(reserve.manifestation.original_title)
    end
  end
end

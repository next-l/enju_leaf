atom_feed(:url => checkouts_url(:format => :atom)) do |feed|
  if @user
    feed.title t('checkout.user_checkout', :login_name => @user.username)
  else
    feed.title t('checkout.library_group_checkout', :library_group_name => @library_group.display_name.localize)
  end
  feed.updated(@checkouts.first ? @checkouts.first.created_at : Time.zone.now)

  @checkouts.each do |checkout|
    feed.entry(checkout) do |entry|
      entry.title(checkout.item.manifestation.original_title)
    end
  end
end

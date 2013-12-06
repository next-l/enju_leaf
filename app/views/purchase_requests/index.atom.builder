atom_feed(:url => purchase_requests_url(:format => :atom)) do |feed|
  if @user
    feed.title t('purchase_request.user_purchase_request', :login_name => @user.username)
  else
    feed.title t('purchase_request.library_group_purchase_request', :library_group_name => @library_group.display_name.localize)
  end
  feed.updated(@purchase_requests.first ? @purchase_requests.first.created_at : Time.zone.now)

  @purchase_requests.each do |purchase_request|
    feed.entry(purchase_request) do |entry|
      entry.title(purchase_request.title)
      entry.author(purchase_request.author)
    end
  end
end

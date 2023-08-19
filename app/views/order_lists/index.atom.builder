atom_feed(url: order_lists_url(format: :atom)) do |feed|
  feed.title t('order_list.library_group_order_list', library_group_name: @library_group.display_name)
  feed.updated(@order_lists.first ? @order_lists.first.created_at : Time.zone.now)

  @order_lists.each do |order_list|
    feed.entry(order_list) do |entry|
      entry.title(order_list.title)
      entry.author(@library_group.display_name)
    end
  end
end

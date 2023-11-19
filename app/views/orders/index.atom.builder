atom_feed(url: orders_url(format: :atom)) do |feed|
  feed.title "Orders at #{@library_group.display_name}"
  feed.updated(@orders.first ? @orders.first.created_at : Time.zone.now)

  @orders.each do |order|
    feed.entry(order) do |entry|
      entry.title order.order_list.title
      entry.author(@library_group.display_name)
    end
  end
end

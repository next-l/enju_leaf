atom_feed(url: news_posts_url(format: :atom)) do |feed|
  feed.title t('news_post.library_group_news_post', library_group_name: @library_group.display_name.localize)
  feed.updated(@news_posts.first ? @news_posts.first.created_at : Time.zone.now)

  @news_posts.each do |news_post|
    feed.entry(news_post) do |entry|
      entry.title(news_post.title)
      entry.author(news_post.user.username)
    end
  end
end

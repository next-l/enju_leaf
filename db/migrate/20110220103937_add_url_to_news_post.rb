class AddUrlToNewsPost < ActiveRecord::Migration[4.2]
  def up
    add_column :news_posts, :url, :string, if_not_exists: true
  end

  def down
    remove_column :news_posts, :url
  end
end

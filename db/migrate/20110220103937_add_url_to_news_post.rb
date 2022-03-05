class AddUrlToNewsPost < ActiveRecord::Migration[4.2]
  def self.up
    add_column :news_posts, :url, :string
  end

  def self.down
    remove_column :news_posts, :url
  end
end

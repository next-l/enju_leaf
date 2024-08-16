class CreateNewsFeeds < ActiveRecord::Migration[4.2]
  def up
    create_table :news_feeds, if_not_exists: true do |t|
      t.integer :library_group_id, default: 1, null: false
      t.string :title
      t.string :url
      t.text :body
      t.integer :position

      t.timestamps
    end
  end

  def down
    drop_table :news_feeds
  end
end

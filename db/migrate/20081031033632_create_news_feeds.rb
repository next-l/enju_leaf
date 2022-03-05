class CreateNewsFeeds < ActiveRecord::Migration[4.2]
  def change
    create_table :news_feeds do |t|
      t.integer :library_group_id, default: 1, null: false
      t.string :title
      t.string :url
      t.text :body
      t.integer :position

      t.timestamps
    end
  end
end

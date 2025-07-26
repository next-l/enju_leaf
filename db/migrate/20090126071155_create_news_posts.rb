class CreateNewsPosts < ActiveRecord::Migration[4.2]
  def up
    create_table :news_posts, if_not_exists: true do |t|
      t.text :title
      t.text :body
      t.integer :user_id
      t.datetime :start_date
      t.datetime :end_date
      t.integer :required_role_id, default: 1, null: false
      t.text :note
      t.integer :position
      t.boolean :draft, default: false, null: false

      t.timestamps
    end
    add_index :news_posts, :user_id
  end

  def down
    drop_table :news_posts
  end
end

class CreateBookmarks < ActiveRecord::Migration[4.2]
  def up
    create_table :bookmarks, if_not_exists: true do |t|
      t.integer :user_id, null: false
      t.integer :manifestation_id
      t.text :title
      t.string :url
      t.text :note
      t.boolean :shared

      t.timestamps
    end

    add_index :bookmarks, :user_id
    add_index :bookmarks, :manifestation_id
    add_index :bookmarks, :url
  end

  def down
    drop_table :bookmarks
  end
end

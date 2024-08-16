class CreateBookmarkStatHasManifestations < ActiveRecord::Migration[4.2]
  def up
    create_table :bookmark_stat_has_manifestations, if_not_exists: true do |t|
      t.integer :bookmark_stat_id, null: false
      t.integer :manifestation_id, null: false
      t.integer :bookmarks_count

      t.timestamps
    end
    add_index :bookmark_stat_has_manifestations, :bookmark_stat_id
    add_index :bookmark_stat_has_manifestations, :manifestation_id
  end

  def down
    drop_table :bookmark_stat_has_manifestations
  end
end

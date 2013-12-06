class CreateBookmarkStatHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :bookmark_stat_has_manifestations do |t|
      t.integer :bookmark_stat_id, :null => false
      t.integer :manifestation_id, :null => false
      t.integer :bookmarks_count

      t.timestamps
    end
    add_index :bookmark_stat_has_manifestations, :bookmark_stat_id
    add_index :bookmark_stat_has_manifestations, :manifestation_id
  end

  def self.down
    drop_table :bookmark_stat_has_manifestations
  end
end

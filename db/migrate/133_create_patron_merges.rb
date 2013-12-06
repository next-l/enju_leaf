class CreatePatronMerges < ActiveRecord::Migration
  def self.up
    create_table :patron_merges do |t|
      t.integer :patron_id, :patron_merge_list_id, :null => false

      t.timestamps
    end
    add_index :patron_merges, :patron_id
    add_index :patron_merges, :patron_merge_list_id
  end

  def self.down
    drop_table :patron_merges
  end
end

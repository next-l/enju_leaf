class CreatePatronMergeLists < ActiveRecord::Migration
  def self.up
    create_table :patron_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :patron_merge_lists
  end
end

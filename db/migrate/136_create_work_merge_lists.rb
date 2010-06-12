class CreateWorkMergeLists < ActiveRecord::Migration
  def self.up
    create_table :work_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :work_merge_lists
  end
end

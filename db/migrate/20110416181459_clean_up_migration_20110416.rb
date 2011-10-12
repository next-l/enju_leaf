class CleanUpMigration20110416 < ActiveRecord::Migration
  def self.up
    remove_column :items, :basket_id
  end

  def self.down
    add_column :items, :basket_id, :integer
  end
end

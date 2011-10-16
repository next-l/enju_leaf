class CleanUpMigration20110416 < ActiveRecord::Migration
  def self.up
    add_index :subjects, :required_role_id
    add_index :participates, :event_id
    add_index :participates, :patron_id
    remove_column :items, :basket_id
  end

  def self.down
    remove_index :subjects, :required_role_id
    remove_index :participates, :event_id
    remove_index :participates, :patron_id
    add_column :items, :basket_id, :integer
  end
end

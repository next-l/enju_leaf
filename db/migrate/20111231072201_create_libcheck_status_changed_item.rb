class CreateLibcheckStatusChangedItem < ActiveRecord::Migration
  def self.up
    create_table :libcheck_status_changed_items do |t|
      t.string :item_identifier, :null => false
      t.integer :item_id, :null => false
      t.integer :circulation_status_id, :null => false
      t.boolean :completed, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :libcheck_status_changed_items
  end
end

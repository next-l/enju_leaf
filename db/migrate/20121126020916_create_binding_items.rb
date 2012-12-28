class CreateBindingItems < ActiveRecord::Migration
  def self.up
    create_table(:binding_items) {|t|
        t.column :bookbinding_id, :integer, :null => false
        t.column :item_id, :integer
        t.timestamps
    }
  end

  def self.down
    drop_table :binding_items
  end
end

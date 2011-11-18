class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      #t.integer :manifestation_id
      t.string :call_number
      t.string :item_identifier
      t.integer :circulation_status_id, :default => 5, :null => false
      t.integer :checkout_type_id, :default => 1, :null => false
      t.timestamps
      t.datetime :deleted_at
      t.integer :shelf_id, :default => 1, :null => false
      t.integer :basket_id
      t.boolean :include_supplements, :default => false, :null => false
      t.integer :checkouts_count, :default => 0, :null => false
      t.integer :owns_count, :default => 0, :null => false
      t.integer :resource_has_subjects_count, :default => 0, :null => false
      t.text :note
      t.string :url
      t.integer :price
      t.integer :lock_version, :default => 0, :null => false
      t.integer :required_role_id, :default => 1, :null => false
      t.string :state
      t.integer :required_score, :default => 0, :null => false
    end
    #add_index :items, :manifestation_id
    add_index :items, :circulation_status_id
    add_index :items, :checkout_type_id
    add_index :items, :shelf_id
    add_index :items, :item_identifier
    add_index :items, :required_role_id
  end

  def self.down
    drop_table :items
  end
end

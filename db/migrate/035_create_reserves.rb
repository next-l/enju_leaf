class CreateReserves < ActiveRecord::Migration
  def self.up
    create_table :reserves do |t|
      t.integer :user_id, :null => false
      t.integer :manifestation_id, :null => false
      t.integer :item_id
      t.integer :request_status_type_id, :null => false
      t.datetime :checked_out_at
      t.timestamps
      t.datetime :canceled_at
      t.datetime :expired_at
      t.datetime :deleted_at
      t.string :state
      t.boolean :expiration_notice_to_patron, :default => false
      t.boolean :expiration_notice_to_library, :default => false
    end

    add_index :reserves, :user_id
    add_index :reserves, :manifestation_id
    add_index :reserves, :item_id
    add_index :reserves, :request_status_type_id
  end

  def self.down
    drop_table :reserves
  end
end

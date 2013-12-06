class CreateUserGroupHasCheckoutTypes < ActiveRecord::Migration
  def self.up
    create_table :user_group_has_checkout_types do |t|
      t.integer :user_group_id, :null => false
      t.integer :checkout_type_id, :null => false
      t.integer :checkout_limit, :default => 0, :null => false
      t.integer :checkout_period, :default => 0, :null => false
      t.integer :checkout_renewal_limit, :default => 0, :null => false
      t.integer :reservation_limit, :default => 0, :null => false
      t.integer :reservation_expired_period, :default => 7, :null => false
      t.boolean :set_due_date_before_closing_day, :default => false, :null => false
      t.datetime :fixed_due_date
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :user_group_has_checkout_types, :user_group_id
    add_index :user_group_has_checkout_types, :checkout_type_id
  end

  def self.down
    drop_table :user_group_has_checkout_types
  end
end

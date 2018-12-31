class CreateCheckoutTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :checkout_types do |t|
      t.string :name, null: false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :checkout_types, :name
  end

  def self.down
    drop_table :checkout_types
  end
end

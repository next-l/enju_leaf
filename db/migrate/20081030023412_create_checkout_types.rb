class CreateCheckoutTypes < ActiveRecord::Migration
  def change
    create_table :checkout_types do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :checkout_types, :name
  end
end

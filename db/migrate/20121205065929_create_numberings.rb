class CreateNumberings < ActiveRecord::Migration
  def change
    create_table :numberings do |t|
      t.string :name
      t.string :display_name
      t.string :prefix
      t.string :suffix
      t.boolean :padding
      t.integer :padding_number
      t.integer :padding_character
      t.string :last_number
      t.integer :checkdigit

      t.timestamps
    end
  end
end

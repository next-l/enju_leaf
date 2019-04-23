class CreateShelves < ActiveRecord::Migration[5.2]
  def change
    create_table :shelves do |t|
      t.string :name, null: false
      t.jsonb :display_name_translations, default: {}, null: false
      t.text :note
      t.references :library, foreign_key: true, null: false
      t.integer :items_count, default: 0, null: false
      t.integer :position
      t.timestamps
    end
  end
end

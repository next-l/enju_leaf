class CreateShelves < ActiveRecord::Migration[5.0]
  def change
    create_table :shelves do |t|
      t.string :name, null: false
      t.jsonb :display_name_translations
      t.text :note
      t.references :library, foreign_key: true, null: false, type: :uuid
      t.integer :items_count, default: 0, null: false
      t.integer :position
      t.timestamps
      t.datetime :deleted_at
    end
  end
end

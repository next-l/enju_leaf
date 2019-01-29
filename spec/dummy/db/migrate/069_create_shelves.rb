class CreateShelves < ActiveRecord::Migration[5.2]
  def change
    create_table :shelves, id: :uuid do |t|
      t.string :name, null: false
      t.jsonb :display_name, default: {}, null: false
      t.text :note
      t.references :library, foreign_key: true, null: false, type: :uuid
      t.integer :items_count, default: 0, null: false
      t.integer :position
      t.timestamps
    end
  end
end

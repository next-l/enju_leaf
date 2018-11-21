class CreateShelves < ActiveRecord::Migration[5.1]
  def change
    create_table :shelves, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, index: {unique: true}, null: false
      t.jsonb :display_name_translations
      t.text :note
      t.references :library, foreign_key: true, null: false, type: :uuid
      t.integer :items_count, default: 0, null: false
      t.integer :position
      t.timestamps
    end
  end
end

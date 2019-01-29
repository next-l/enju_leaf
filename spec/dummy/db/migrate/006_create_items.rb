class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items, id: :uuid do |t|
      t.string :call_number
      t.string :item_identifier, index: {unique: true}
      t.timestamps
      t.references :shelf, type: :uuid
      t.boolean :include_supplements, default: false, null: false
      t.text :note
      t.string :url
      t.integer :price
      t.integer :lock_version, default: 0, null: false
      t.integer :required_role_id, default: 1, null: false
    end
  end
end

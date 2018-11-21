class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :manifestation, type: :uuid, foreign_key: true, null: false
      t.string :call_number
      t.string :item_identifier, index: {unique: true}
      t.timestamps
      t.boolean :include_supplements, default: false, null: false
      t.text :note
      t.string :url
      t.integer :price
      t.integer :lock_version, default: 0, null: false
      t.integer :required_role_id, null: false, default: 1
    end
  end
end

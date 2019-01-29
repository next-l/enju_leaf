class CreateIdentifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :identifiers do |t|
      t.string :body, null: false
      t.integer :identifier_type_id, null: false, index: true
      t.references :manifestation, foreign_key: true, null: false, type: :uuid
      t.boolean :primary
      t.integer :position

      t.timestamps
    end
  end
end

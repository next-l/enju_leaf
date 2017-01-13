class CreateIdentifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :identifiers do |t|
      t.string :body, null: false
      t.integer :identifier_type_id, null: false
      t.references :manifestation, foreign_key: true, type: :uuid
      t.boolean :primary
      t.integer :position

      t.timestamps
    end
    add_index :identifiers, [:body, :identifier_type_id]
  end
end

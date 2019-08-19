class CreateIdentifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :identifiers do |t|
      t.string :body, null: false
      t.integer :identifier_type_id, null: false
      t.integer :manifestation_id
      t.boolean :primary
      t.integer :position

      t.timestamps
    end
    add_index :identifiers, [:body, :identifier_type_id]
    add_index :identifiers, :manifestation_id
  end
end

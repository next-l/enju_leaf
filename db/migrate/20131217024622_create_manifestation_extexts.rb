class CreateManifestationExtexts < ActiveRecord::Migration
  def change
    create_table :manifestation_extexts do |t|
      t.string :name
      t.text :value
      t.integer :manifestation_id, null: false
      t.integer :position, null: false, :default => 0

      t.timestamps
    end
  end
end

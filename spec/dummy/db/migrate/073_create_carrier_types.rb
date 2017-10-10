class CreateCarrierTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :carrier_types do |t|
      t.string :name, null: false
      t.jsonb :display_name_translations
      t.text :note
      t.integer :position
      t.timestamps
    end
  end
end

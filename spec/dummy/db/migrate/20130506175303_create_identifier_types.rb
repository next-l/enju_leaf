class CreateIdentifierTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :identifier_types do |t|
      t.string :name, index: {unique: true}, null: false
      t.jsonb :display_name_translations, default: {}, null: false
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end

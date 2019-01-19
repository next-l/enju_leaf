class CreateCreateTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :create_types do |t|
      t.string :name
      t.jsonb :display_name, default: {}, null: false
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end

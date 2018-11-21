class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table 'roles' do |t|
      t.string :name, null: false
      t.jsonb :display_name_translations
      t.text :note
      t.timestamps
      t.integer :score, default: 0, null: false
      t.integer :position
    end
  end
end

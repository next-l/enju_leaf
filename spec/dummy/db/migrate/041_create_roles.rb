class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table "roles" do |t|
      t.string :name, null: false
      t.jsonb :display_name, default: {}, null: false
      t.text :note
      t.integer :score, default: 0, null: false
      t.integer :position
      t.timestamps
    end
  end
end

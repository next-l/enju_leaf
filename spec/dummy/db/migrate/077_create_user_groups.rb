class CreateUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_groups do |t|
      t.string :name, not_null: true
      t.jsonb :display_name, default: {}, null: false
      t.text :note
      t.integer :position
      t.timestamps
    end
  end
end

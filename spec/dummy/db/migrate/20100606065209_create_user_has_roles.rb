class CreateUserHasRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :user_has_roles do |t|
      t.references :user, foreign_key: {on_delete: :cascade}, null: false
      t.references :role, foreign_key: true, null: false

      t.timestamps
    end
  end
end

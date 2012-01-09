class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.string :name, :string, :not_null => true
      t.text :display_name, :string
      t.text :note
      t.integer :position
      t.timestamps
      t.datetime :deleted_at
    end
  end
end

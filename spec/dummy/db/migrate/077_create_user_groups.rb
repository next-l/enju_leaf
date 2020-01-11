class CreateUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_groups do |t|
      t.string :name, not_null: true
      t.text :note, comment: '備考'
      t.integer :position
      t.timestamps
    end
  end
end

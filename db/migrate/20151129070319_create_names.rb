class CreateNames < ActiveRecord::Migration
  def change
    create_table :names do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.integer :language_id
      t.integer :profile_id
      t.integer :position

      t.timestamps null: false
    end
    add_index :names, :profile_id
  end
end

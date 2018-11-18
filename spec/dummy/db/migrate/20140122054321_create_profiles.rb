class CreateProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.integer :user_group_id
      t.integer :library_id
      t.string :locale
      t.string :user_number
      t.text :full_name
      t.text :note
      t.text :keyword_list
      t.integer :required_role_id

      t.timestamps
    end

    add_index :profiles, :user_id
    add_index :profiles, :user_number, unique: true
  end
end

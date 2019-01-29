class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles, id: :uuid do |t|
      t.references :user_group, type: :uuid, null: false
      t.references :library, type: :uuid
      t.string :locale
      t.string :user_number, unique: true
      t.text :full_name
      t.text :note
      t.text :keyword_list
      t.references :required_role, index: false, null: false

      t.timestamps
    end
  end
end

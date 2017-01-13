class CreateUserGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :user_groups, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: true
      t.jsonb :display_name_translations
      t.text :note
      t.integer :position
      t.timestamps
      t.datetime :deleted_at
    end
  end
end

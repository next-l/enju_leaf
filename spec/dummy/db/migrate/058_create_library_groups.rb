class CreateLibraryGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :library_groups, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, index: {unique: true}, null: false
      t.jsonb :display_name_translations
      t.string :short_name, index: {unique: true}, null: false
      t.text :my_networks
      t.jsonb :login_banner_translations
      t.text :note
      t.integer :country_id
      t.integer :position

      t.timestamps
    end
  end
end

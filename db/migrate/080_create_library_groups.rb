class CreateLibraryGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :library_groups do |t|
      t.string :name, null: false
      t.text :display_name
      t.string :short_name, index: true, null: false
      t.text :my_networks
      t.text :login_banner
      t.text :note
      t.integer :country_id
      t.integer :position

      t.timestamps
    end
  end
end

class CreateLibraryGroups < ActiveRecord::Migration
  def change
    create_table :library_groups do |t|
      t.string :name, :null => false
      t.text :display_name
      t.string :short_name, :null => false
      t.cidr :my_networks
      t.text :login_banner
      t.text :note
      t.integer :country_id
      t.integer :position

      t.timestamps
    end
    add_index :library_groups, :short_name
  end
end

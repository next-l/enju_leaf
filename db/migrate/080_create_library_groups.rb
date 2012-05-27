class CreateLibraryGroups < ActiveRecord::Migration
  def change
    create_table :library_groups do |t|
      t.string :name, :null => false
      t.text :display_name
      t.string :short_name, :null => false
      t.string :email
      t.text :my_networks
      t.boolean :use_dsbl, :default => false, :null => false
      t.text :dsbl_list
      t.text :login_banner
      t.text :note
      t.integer :valid_period_for_new_user, :default => 365, :null => false
      t.integer :country_id

      t.timestamps
    end
    add_index :library_groups, :short_name
  end
end

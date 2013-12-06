class CreateSearchEngines < ActiveRecord::Migration
  def self.up
    create_table :search_engines do |t|
      t.string :name, :null => false
      t.text :display_name
      t.string :url, :null => false
      t.text :base_url, :null => false
      t.text :http_method, :null => false
      t.text :query_param, :null => false
      t.text :additional_param
      t.text :note
      #t.integer :library_group_id, :default => 1, :null => false
      t.integer :position

      t.timestamps
    end
    #add_index :search_engines, :library_group_id
  end

  def self.down
    drop_table :search_engines
  end
end

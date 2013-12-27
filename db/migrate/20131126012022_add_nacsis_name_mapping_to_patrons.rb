class AddNacsisNameMappingToPatrons < ActiveRecord::Migration
  def change
    add_column :patrons, :source, :integer
    add_column :patrons, :marcid, :string
    add_column :patrons, :lcaid, :string

    add_index  :patrons, ["source"], :name => "index_patrons_on_source", :unique => false
    add_index  :patrons, ["marcid"], :name => "index_patrons_on_marcid", :unique => false
    add_index  :patrons, ["lcaid"],  :name => "index_patrons_on_lcaid",  :unique => true
  end
end

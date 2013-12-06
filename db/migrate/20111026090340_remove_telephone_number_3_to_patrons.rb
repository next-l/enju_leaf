class RemoveTelephoneNumber3ToPatrons < ActiveRecord::Migration
  def self.up
    remove_column :patrons, :telephone_number_3
  end

  def self.down
    add_column :patrons, :telephone_number_3, :string
  end
end

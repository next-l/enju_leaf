class AddTelephoneNumber3 < ActiveRecord::Migration
  def self.up
    add_column :patrons, :telephone_number_3, :string
  end

  def self.down
    remove_column :patrons, :telephone_number_3
  end
end

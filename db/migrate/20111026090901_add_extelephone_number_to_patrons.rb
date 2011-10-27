class AddExtelephoneNumberToPatrons < ActiveRecord::Migration
  def self.up
    add_column :patrons, :extelephone_number_1, :string
    add_column :patrons, :extelephone_number_2, :string
    add_column :patrons, :telephone_number_1_type_id, :integer
    add_column :patrons, :telephone_number_2_type_id, :integer
    add_column :patrons, :extelephone_number_1_type_id, :integer
    add_column :patrons, :extelephone_number_2_type_id, :integer
    add_column :patrons, :fax_number_1_type_id, :integer
    add_column :patrons, :fax_number_2_type_id, :integer
  end

  def self.down
    remove_column :patrons, :extelephone_number_1
    remove_column :patrons, :extelephone_number_2
    remove_column :patrons, :telephone_number_1_type_id
    remove_column :patrons, :telephone_number_2_type_id
    remove_column :patrons, :extelephone_number_1_type_id
    remove_column :patrons, :extelephone_number_2_type_id
    remove_column :patrons, :fax_number_1_type_id
    remove_column :patrons, :fax_number_2_type_id
  end
end

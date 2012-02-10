class AddColumnForPatronIdentifierToPatron < ActiveRecord::Migration
  def self.up
    add_column :patrons, :patron_identifier, :string
    add_index :patrons, :patron_identifier
  end

  def self.down
    remove_index :patrons, :patron_identifier
    remove_column :patrons, :patron_identifier
  end
end

class AddColumnForPatronIdentifierToPatron < ActiveRecord::Migration
  def self.up
    add_column :patrons, :patron_identifier, :string
  end

  def self.down
    remove_column :patrons, :patron_identifier
  end
end

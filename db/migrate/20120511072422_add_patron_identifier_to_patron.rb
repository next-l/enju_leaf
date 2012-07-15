class AddPatronIdentifierToPatron < ActiveRecord::Migration
  def change
    add_column :patrons, :patron_identifier, :string
    add_index :patrons, :patron_identifier
  end
end

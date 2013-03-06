class AddBirthDateAndDeathDateToPatron < ActiveRecord::Migration
  def self.up
    add_column :patrons, :birth_date, :string
    add_column :patrons, :death_date, :string
  end

  def self.down
    remove_column :patrons, :death_date
    remove_column :patrons, :birth_date
  end
end

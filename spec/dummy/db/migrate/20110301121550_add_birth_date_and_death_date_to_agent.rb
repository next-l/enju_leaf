class AddBirthDateAndDeathDateToAgent < ActiveRecord::Migration[5.1]
  def self.up
    add_column :agents, :birth_date, :string
    add_column :agents, :death_date, :string
  end

  def self.down
    remove_column :agents, :death_date
    remove_column :agents, :birth_date
  end
end

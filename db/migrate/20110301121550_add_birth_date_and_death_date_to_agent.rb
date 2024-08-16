class AddBirthDateAndDeathDateToAgent < ActiveRecord::Migration[4.2]
  def up
    add_column :agents, :birth_date, :string
    add_column :agents, :death_date, :string
  end

  def down
    remove_column :agents, :death_date
    remove_column :agents, :birth_date
  end
end

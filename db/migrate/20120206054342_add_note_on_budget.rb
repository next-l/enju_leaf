class AddNoteOnBudget < ActiveRecord::Migration
  def self.up
    add_column :budgets, :note, :string
  end

  def self.down
    remoce_column :budgets, :note
  end
end

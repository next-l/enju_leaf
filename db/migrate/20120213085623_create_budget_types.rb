class CreateBudgetTypes < ActiveRecord::Migration
  def self.up
    create_table :budget_types do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :budget_types
  end
end

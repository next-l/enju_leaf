class CreateBudgets < ActiveRecord::Migration
  def self.up
    create_table :budgets do |t|
      t.integer :library_id
      t.integer :term_id
      t.integer :amount
    end
  end

  def self.down
    drop_table :budgets
  end
end

class CreateExpenses < ActiveRecord::Migration
  def self.up
    create_table :expenses do |t|
      t.integer :budget_id
      t.integer :item_id
      t.integer :price
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :expenses
  end
end

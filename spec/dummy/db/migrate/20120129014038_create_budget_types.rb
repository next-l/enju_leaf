class CreateBudgetTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_types do |t|
      t.string :name, index: {unique: true}, null: false
      t.text :display_name, null: false
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end

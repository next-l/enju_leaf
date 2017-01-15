class CreateLendingPolicies < ActiveRecord::Migration[5.0]
  def change
    create_table :lending_policies do |t|
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.references :user_group, null: false, foreign_key: true, type: :uuid
      t.integer :loan_period, default: 0, null: false
      t.datetime :fixed_due_date
      t.integer :renewal, default: 0, null: false
      t.integer :fine, default: 0, null: false
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :lending_policies, [:item_id, :user_group_id], unique: true
  end
end

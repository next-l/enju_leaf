class CreateCheckedItems < ActiveRecord::Migration[5.2]
  def change
    create_table :checked_items do |t|
      t.references :item, foreign_key: true, null: false
      t.references :basket, foreign_key: true, null: false
      t.references :librarian, index: true
      t.datetime :due_date, null: false

      t.timestamps
    end
  end
end

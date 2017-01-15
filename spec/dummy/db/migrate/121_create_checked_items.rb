class CreateCheckedItems < ActiveRecord::Migration[5.0]
  def change
    create_table :checked_items do |t|
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.references :basket, null: false, foreign_key: {on_delete: :nullify}
      t.datetime :due_date, null: false

      t.timestamps
    end
  end
end

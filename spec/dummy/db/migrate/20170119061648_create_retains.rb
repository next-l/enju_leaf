class CreateRetains < ActiveRecord::Migration[5.1]
  def change
    create_table :retains do |t|
      t.references :reserve, foreign_key: {on_delete: :cascade}, null: false, type: :uuid
      t.references :item, foreign_key: {on_delete: :cascade}, null: false, type: :uuid

      t.timestamps
    end
  end
end

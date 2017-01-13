class CreateWithdraws < ActiveRecord::Migration[5.0]
  def change
    create_table :withdraws do |t|
      t.references :basket, foreign_key: {on_delete: :nullify}
      t.references :item, foreign_key: true, type: :uuid
      t.integer :librarian_id

      t.timestamps null: false
    end
  end
end

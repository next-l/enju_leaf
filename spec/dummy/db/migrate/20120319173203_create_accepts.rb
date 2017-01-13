class CreateAccepts < ActiveRecord::Migration[5.0]
  def change
    create_table :accepts do |t|
      t.references :basket, foreign_key: {on_delete: :nullify}
      t.references :item, foreign_key: true, type: :uuid
      t.integer :librarian_id

      t.timestamps
    end
  end
end

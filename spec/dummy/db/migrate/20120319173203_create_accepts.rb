class CreateAccepts < ActiveRecord::Migration[5.2]
  def change
    create_table :accepts do |t|
      t.references :basket, foreign_key: true
      t.references :item, type: :uuid
      t.references :librarian, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end

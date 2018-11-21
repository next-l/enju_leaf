class CreateRealizes < ActiveRecord::Migration[5.1]
  def change
    create_table :realizes do |t|
      t.references :agent, null: false, foreign_key: true, type: :uuid
      t.references :expression, null: false, foreign_key: {to_table: :manifestations}, type: :uuid
      t.integer :position

      t.timestamps
    end
  end
end

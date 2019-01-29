class CreateRealizes < ActiveRecord::Migration[5.2]
  def change
    create_table :realizes do |t|
      t.references :agent, foreign_key: true, null: false, type: :uuid
      t.references :expression, null: false, type: :uuid, foreign_key: {to_table: :manifestations}
      t.integer :position

      t.timestamps
    end
  end
end

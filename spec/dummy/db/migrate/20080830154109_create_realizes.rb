class CreateRealizes < ActiveRecord::Migration[5.1]
  def change
    create_table :realizes do |t|
      t.references :agent, null: false, index: true
      t.references :expression, null: false, index: true, type: :uuid
      t.integer :position

      t.timestamps
    end
  end
end

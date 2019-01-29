class CreateCreates < ActiveRecord::Migration[5.2]
  def change
    create_table :creates do |t|
      t.references :agent, foreign_key: true, null: false, type: :uuid
      t.references :work, null: false, type: :uuid, foreign_key: {to_table: :manifestations}
      t.integer :position
      t.timestamps
    end
  end
end

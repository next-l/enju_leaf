class CreateCreates < ActiveRecord::Migration[5.0]
  def change
    create_table :creates do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :work, null: false, index: true, type: :uuid
      t.integer :position
      t.timestamps
    end
  end
end

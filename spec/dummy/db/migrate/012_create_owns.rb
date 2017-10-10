class CreateOwns < ActiveRecord::Migration[5.1]
  def change
    create_table :owns do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.integer :position
      t.timestamps
    end
  end
end

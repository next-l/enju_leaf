class CreateOwns < ActiveRecord::Migration[5.2]
  def change
    create_table :owns do |t|
      t.references :agent, null: false
      t.references :item, null: false
      t.integer :position
      t.timestamps
    end
  end
end

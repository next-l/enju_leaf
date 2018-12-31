class CreateOwns < ActiveRecord::Migration[4.2]
  def change
    create_table :owns do |t|
      t.references :agent, null: false
      t.references :item, null: false
      t.integer :position
      t.timestamps
    end
    add_index :owns, :agent_id
    add_index :owns, :item_id
  end
end

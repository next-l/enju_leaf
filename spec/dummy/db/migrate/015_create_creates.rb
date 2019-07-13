class CreateCreates < ActiveRecord::Migration[4.2]
  def change
    create_table :creates do |t|
      t.references :agent, null: false
      t.references :work, null: false
      t.integer :position
      t.timestamps
    end
    add_index :creates, :agent_id
    add_index :creates, :work_id
  end
end

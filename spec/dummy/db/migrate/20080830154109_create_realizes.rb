class CreateRealizes < ActiveRecord::Migration
  def change
    create_table :realizes do |t|
      t.references :agent, :null => false
      t.references :expression, :null => false
      t.integer :position

      t.timestamps
    end
    add_index :realizes, :agent_id
    add_index :realizes, :expression_id
  end
end

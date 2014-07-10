class CreateParticipates < ActiveRecord::Migration
  def self.up
    create_table :participates do |t|
      t.integer :agent_id, :null => false
      t.integer :event_id, :null => false
      t.integer :position

      t.timestamps
    end
    add_index :participates, :event_id
    add_index :participates, :agent_id
  end

  def self.down
    drop_table :participates
  end
end

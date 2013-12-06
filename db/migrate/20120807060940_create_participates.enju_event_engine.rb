# This migration comes from enju_event_engine (originally 20090519203307)
class CreateParticipates < ActiveRecord::Migration
  def self.up
    create_table :participates do |t|
      t.integer :patron_id, :null => false
      t.integer :event_id, :null => false
      t.integer :position

      t.timestamps
    end
    add_index :participates, :event_id
    add_index :participates, :patron_id
  end

  def self.down
    drop_table :participates
  end
end

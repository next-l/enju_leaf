class CreateParticipates < ActiveRecord::Migration
  def self.up
    create_table :participates do |t|
      t.integer :patron_id, :null => false
      t.integer :event_id, :null => false
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :participates
  end
end

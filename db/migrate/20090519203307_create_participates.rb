class CreateParticipates < ActiveRecord::Migration[4.2]
  def up
    create_table :participates do |t|
      t.references :agent, index: true, null: false
      t.references :event, index: true, null: false
      t.integer :position

      t.timestamps
    end
  end

  def down
    drop_table :participates
  end
end

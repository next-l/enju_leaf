class CreateSystemConfigrations < ActiveRecord::Migration
  def self.up
    create_table :system_configrations do |t|
      t.string :keyname, :null => false
      t.string :v
      t.timestamps
    end
  end

  def self.down
    drop_table :system_configrations
  end
end

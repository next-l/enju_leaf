class CreateAccessLogs < ActiveRecord::Migration
  def self.up
    create_table :access_logs do |t|
      t.datetime :date
      t.string :log_type
      t.integer :value
      t.timestamps
      t.boolean
    end
  end

  def self.down
    drop_table :access_logs
  end
end

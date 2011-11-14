class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.integer :yyyymmdd
      t.integer :yyyymm
      t.integer :dd
      t.integer :data_type
      t.integer :library_id, :default => 0
      t.integer :value
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :statistics
  end
end

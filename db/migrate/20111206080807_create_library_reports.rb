class CreateLibraryReports < ActiveRecord::Migration
  def self.up
    create_table :library_reports do |t|
      t.integer :yyyymm
      t.integer :yyyymmdd
      t.integer :library_id
      t.integer :visiters
      t.integer :copies
      t.integer :consultations
      t.timestamps
    end
  end

  def self.down
    drop_table :library_reports
  end
end

class CreateSeriesStatementMergeLists < ActiveRecord::Migration
  def self.up
    create_table :series_statement_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :series_statement_merge_lists
  end
end

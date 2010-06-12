class CreateSeriesStatements < ActiveRecord::Migration
  def self.up
    create_table :series_statements do |t|
      t.text :title
      t.text :numbering
      t.text :title_subseries
      t.text :numbering_subseries
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :series_statements
  end
end

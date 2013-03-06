class CreateSeriesStatements < ActiveRecord::Migration
  def change
    create_table :series_statements do |t|
      t.text :title
      t.text :numbering
      t.text :title_subseries
      t.text :numbering_subseries
      t.integer :position

      t.timestamps
    end
  end
end

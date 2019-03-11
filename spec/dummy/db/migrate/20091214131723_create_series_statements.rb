class CreateSeriesStatements < ActiveRecord::Migration[5.2]
  def change
    create_table :series_statements, id: :uuid do |t|
      t.text :title, null: false
      t.text :numbering
      t.text :title_subseries
      t.text :numbering_subseries
      t.integer :position

      t.timestamps
    end
  end
end

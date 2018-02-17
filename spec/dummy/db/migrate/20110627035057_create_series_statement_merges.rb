class CreateSeriesStatementMerges < ActiveRecord::Migration[5.1]
  def change
    create_table :series_statement_merges do |t|
      t.references :series_statement, foreign_key: true
      t.references :series_statement_merge_list, foreign_key: true

      t.timestamps
    end
  end
end

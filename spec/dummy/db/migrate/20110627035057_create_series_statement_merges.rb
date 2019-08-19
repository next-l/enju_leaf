class CreateSeriesStatementMerges < ActiveRecord::Migration[5.2]
  def change
    create_table :series_statement_merges do |t|
      t.integer :series_statement_id, null: false
      t.integer :series_statement_merge_list_id, null: false

      t.timestamps
    end
    add_index :series_statement_merges, :series_statement_id
    add_index :series_statement_merges, :series_statement_merge_list_id, name: "index_series_statement_merges_on_list_id"
  end
end

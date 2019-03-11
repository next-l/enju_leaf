class CreateSeriesStatementMerges < ActiveRecord::Migration[5.2]
  def change
    create_table :series_statement_merges do |t|
      t.references :series_statement, foreign_key: true, null: false, type: :uuid
      t.references :series_statement_merge_list, foreign_key: true, index: false, null: false, type: :uuid

      t.timestamps
    end
    add_index :series_statement_merges, :series_statement_merge_list_id, name: "index_series_statement_merges_on_list_id"
  end
end

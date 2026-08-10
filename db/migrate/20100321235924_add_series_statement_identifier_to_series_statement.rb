class AddSeriesStatementIdentifierToSeriesStatement < ActiveRecord::Migration[4.2]
  def up
    add_column :series_statements, :series_statement_identifier, :string
    add_index :series_statements, :series_statement_identifier
  end

  def down
    remove_column :series_statements, :series_statement_identifier
  end
end

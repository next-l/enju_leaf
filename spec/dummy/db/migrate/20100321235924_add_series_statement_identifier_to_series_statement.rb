class AddSeriesStatementIdentifierToSeriesStatement < ActiveRecord::Migration[5.2]
  def self.up
    add_column :series_statements, :series_statement_identifier, :string
    add_index :series_statements, :series_statement_identifier
  end

  def self.down
    remove_column :series_statements, :series_statement_identifier
  end
end

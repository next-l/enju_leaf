class AddSeriesStatementIdentifierToSeriesStatement < ActiveRecord::Migration
  def self.up
    add_column :series_statements, :series_statement_identifier, :string
    add_index :series_statements, :series_statement_identifier
  end

  def self.down
    remove_column :series_statements, :series_statement_identifier
  end
end

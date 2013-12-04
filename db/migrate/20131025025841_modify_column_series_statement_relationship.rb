class ModifyColumnSeriesStatementRelationship < ActiveRecord::Migration
  def up
    remove_column :series_statement_relationships, :parent_id 
    remove_column :series_statement_relationships, :child_id 
    remove_column :series_statement_relationships, :position
    add_column    :series_statement_relationships, :relationship_family_id,                   :integer, :null => false
    add_column    :series_statement_relationships, :seq,                                      :string, :null => false
    add_column    :series_statement_relationships, :before_series_statement_relationship_id,  :integer
    add_column    :series_statement_relationships, :after_series_statement_relationship_id,   :integer
    add_column    :series_statement_relationships, :series_statement_relationship_type_id,    :integer, :null => false
    add_column    :series_statement_relationships, :source,                                   :integer, :null => false, :default => 0
  end

  def down
    remove_column :series_statement_relationships, :relationship_family_id
    remove_column :series_statement_relationships, :seq
    remove_column :series_statement_relationships, :before_series_statement_relationship_id
    remove_column :series_statement_relationships, :after_series_statement_relationship_id
    remove_column :series_statement_relationships, :series_statement_relationship_type_id
    remove_column :series_statement_relationships, :source
    add_column    :series_statement_relationships, :parent_id, :integer
    add_column    :series_statement_relationships, :child_id,  :integer
    add_column    :series_statement_relationships, :position,  :integer
  end
end

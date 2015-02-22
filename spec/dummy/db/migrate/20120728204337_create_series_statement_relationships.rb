class CreateSeriesStatementRelationships < ActiveRecord::Migration
  def change
    create_table :series_statement_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :position

      t.timestamps
    end
  end
end

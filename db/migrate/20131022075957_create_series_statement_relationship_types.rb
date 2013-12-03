class CreateSeriesStatementRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :series_statement_relationship_types do |t|
      t.string :display_name
      t.integer :typeid, :null => false
      t.integer :position
      t.text :note

      t.timestamps
    end
  end
end

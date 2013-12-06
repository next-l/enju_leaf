class CreateExpressionMerges < ActiveRecord::Migration
  def self.up
    create_table :expression_merges do |t|
      t.integer :expression_id, :expression_merge_list_id, :null => false

      t.timestamps
    end
    add_index :expression_merges, :expression_id
    add_index :expression_merges, :expression_merge_list_id
  end

  def self.down
    drop_table :expression_merges
  end
end

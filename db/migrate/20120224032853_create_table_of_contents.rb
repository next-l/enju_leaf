class CreateTableOfContents < ActiveRecord::Migration
  def change
    create_table :table_of_contents do |t|
      t.integer :manifestaion_id
      t.integer :display_order
      t.integer :contents_level
      t.string :note
      t.integer :pagenumber

      t.timestamps
    end
    add_index :table_of_contents, [:manifestaion_id, :display_order, :contents_level], :name => 'table_of_contents_idx01'
  end
end

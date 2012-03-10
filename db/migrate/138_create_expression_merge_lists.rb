class CreateExpressionMergeLists < ActiveRecord::Migration
  def change
    create_table :expression_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end
end

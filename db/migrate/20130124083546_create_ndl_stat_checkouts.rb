class CreateNdlStatCheckouts < ActiveRecord::Migration
  def change
    create_table :ndl_stat_checkouts do |t|
      t.string :item_type, :null => false
      t.integer :user, :null => false
      t.integer :item, :null => false
      t.references :ndl_statistic, :null => false

      t.timestamps
    end
    add_index :ndl_stat_checkouts, :ndl_statistic_id
  end
end

class CreateNdlStatAccepts < ActiveRecord::Migration
  def change
    create_table :ndl_stat_accepts do |t|
      t.string :item_type, :null => false
      t.string :region, :null => false
      t.integer :purchase, :null => false
      t.integer :donation, :null => false
      t.integer :production, :null => false
      t.references :ndl_statistic, :null => false

      t.timestamps
    end
    add_index :ndl_stat_accepts, :ndl_statistic_id
  end
end

class CreateNdlStatManifestations < ActiveRecord::Migration
  def change
    create_table :ndl_stat_manifestations do |t|
      t.string :item_type, :null => false
      t.string :region
      t.integer :previous_term_end_count, :null => false
      t.integer :inc_count, :null => false
      t.integer :dec_count, :null => false
      t.integer :current_term_end_count, :null => false
      t.references :ndl_statistic, :null => false

      t.timestamps
    end
    add_index :ndl_stat_manifestations, :ndl_statistic_id
  end
end

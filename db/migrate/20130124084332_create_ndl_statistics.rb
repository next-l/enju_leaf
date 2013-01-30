class CreateNdlStatistics < ActiveRecord::Migration
  def change
    create_table :ndl_statistics do |t|
      t.integer :term_id, :null => false
      t.integer :ndl_stat_manifestation_id
      t.integer :ndl_stat_accept_id
      t.integer :ndl_stat_checkout_id

      t.timestamps
    end
  end
end

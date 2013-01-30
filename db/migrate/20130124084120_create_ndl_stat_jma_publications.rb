class CreateNdlStatJmaPublications < ActiveRecord::Migration
  def change
    create_table :ndl_stat_jma_publications do |t|
      t.string :original_title, :null => false
      t.string :number_string, :null => false
      t.references :ndl_statistic, :null => false

      t.timestamps
    end
    add_index :ndl_stat_jma_publications, :ndl_statistic_id
  end
end

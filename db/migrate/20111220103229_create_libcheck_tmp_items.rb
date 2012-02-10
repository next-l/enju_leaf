class CreateLibcheckTmpItems < ActiveRecord::Migration
  def self.up
    create_table :libcheck_tmp_items do |t|
      t.string :item_identifier, :null => false
      t.integer :item_id
      t.integer :no, :null => false
      t.string :ndc
      t.string :class_type1
      t.string :class_type2
      t.integer :shelf_id
      t.integer :confusion_flg, :default => 0
      t.integer :status_flg, :default => 0

      t.text :original_title
      t.timestamp :date_of_publication
      t.string :edition_display_value
    end
  end

  def self.down
    drop_table :libcheck_tmp_items
  end
end

class LibcheckTmpItems < ActiveRecord::Migration
  def self.up
    #add_column :libcheck_tmp_items, :original_title, :text
    add_column :libcheck_tmp_items, :original_title, :text
    add_column :libcheck_tmp_items, :date_of_publication, :timestamp
    add_column :libcheck_tmp_items, :edition_display_value, :string
  end

  def self.down
    #remove_column :libcheck_tmp_items, :original_title
    remove_column :libcheck_tmp_items, :original_title
    remove_column :libcheck_tmp_items, :date_of_publication
    remove_column :libcheck_tmp_items, :edition_display_value
  end
end

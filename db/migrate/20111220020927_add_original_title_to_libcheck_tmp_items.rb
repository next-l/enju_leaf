class AddOriginalTitleToLibcheckTmpItems < ActiveRecord::Migration
  def self.up
    add_column :libcheck_tmp_items, :original_title, :text
  end

  def self.down
    remove_column :libcheck_tmp_items, :original_title
  end
end

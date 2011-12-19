class UpdateLibcheckTmpItemsForExport < ActiveRecord::Migration
  def self.up
    add_column :libcheck_tmp_items, :date_of_publication, :datetime
    add_column :libcheck_tmp_items, :edition_display_value, :string
  end

  def self.down
    remove_column :libcheck_tmp_items, :date_of_publication
    remove_column :libcheck_tmp_items, :edition_display_value
  end
end

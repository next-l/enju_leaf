class AddColumnOriginalTitleAndNoteToInventoryCheckResults < ActiveRecord::Migration
  def change
    add_column :inventory_check_results, :original_title, :string
    add_column :inventory_check_results, :note, :text
    add_column :inventory_check_results, :shelf_group_names, :text
  end
end

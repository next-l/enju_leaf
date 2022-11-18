class ChangeColumnCheckoutsShelfIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    change_column :checkouts, :shelf_id, :bigint
    change_column :items, :shelf_id, :bigint
    change_column :resource_import_files, :default_shelf_id, :bigint
  end
end

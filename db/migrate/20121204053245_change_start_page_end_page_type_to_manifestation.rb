class ChangeStartPageEndPageTypeToManifestation < ActiveRecord::Migration
  def up
    change_column :manifestations, :start_page, :string
    change_column :manifestations, :end_page, :string
  end

  def down
    change_column :manifestations, :start_page, :integer
    change_column :manifestations, :end_page, :integer
  end
end

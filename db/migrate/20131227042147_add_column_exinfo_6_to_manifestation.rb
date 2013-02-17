class AddColumnExinfo6ToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :exinfo_6, :string
    add_column :manifestations, :exinfo_7, :string
    add_column :manifestations, :exinfo_8, :string
    add_column :manifestations, :exinfo_9, :string
    add_column :manifestations, :exinfo_10, :string
  end
end

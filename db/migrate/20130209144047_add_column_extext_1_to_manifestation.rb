class AddColumnExtext1ToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :extext_1, :text
    add_column :manifestations, :extext_2, :text
    add_column :manifestations, :extext_3, :text
    add_column :manifestations, :extext_4, :text
    add_column :manifestations, :extext_5, :text
  end
end

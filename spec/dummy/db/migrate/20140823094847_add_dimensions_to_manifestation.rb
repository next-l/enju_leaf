class AddDimensionsToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :dimensions, :text
  end
end

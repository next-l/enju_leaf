class AddPublicationPlaceToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :publication_place, :text
  end
end

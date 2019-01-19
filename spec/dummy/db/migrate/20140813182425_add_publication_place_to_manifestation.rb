class AddPublicationPlaceToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :publication_place, :text
  end
end

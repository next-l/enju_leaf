class AddContentTypeIdToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :content_type_id, :integer

  end
end

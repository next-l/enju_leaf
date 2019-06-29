class AddFulltextContentToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :fulltext_content, :boolean
  end
end

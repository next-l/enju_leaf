class AddFulltextContentToManifestation < ActiveRecord::Migration[5.1]
  def change
    add_column :manifestations, :fulltext_content, :boolean
  end
end

class AddFulltextContentToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :fulltext_content, :boolean
  end
end

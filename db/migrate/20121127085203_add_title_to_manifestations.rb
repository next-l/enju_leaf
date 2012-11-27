class AddTitleToManifestations < ActiveRecord::Migration
  def change
    add_column :manifestations, :article_title, :text
  end
end

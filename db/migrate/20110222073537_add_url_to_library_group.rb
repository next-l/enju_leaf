class AddUrlToLibraryGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :library_groups, :url, :string, default: 'http://localhost:3000/'
  end

  def down
    remove_column :library_groups, :url
  end
end

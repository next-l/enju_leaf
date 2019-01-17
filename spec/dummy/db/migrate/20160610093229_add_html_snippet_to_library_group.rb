class AddHtmlSnippetToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :html_snippet, :text
  end
end

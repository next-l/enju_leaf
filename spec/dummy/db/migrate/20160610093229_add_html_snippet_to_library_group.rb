class AddHtmlSnippetToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :library_groups, :html_snippet, :text
  end
end

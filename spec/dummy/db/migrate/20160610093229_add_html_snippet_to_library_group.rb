class AddHtmlSnippetToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :html_snippet, :text
  end
end

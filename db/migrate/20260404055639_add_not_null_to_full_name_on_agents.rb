class AddNotNullToFullNameOnAgents < ActiveRecord::Migration[7.2]
  def change
    change_column_null :agents, :full_name, false
    change_column_null :agent_merge_lists, :title, false
    change_column_null :colors, :code, false
    change_column_null :colors, :property, false
    change_column_null :library_groups, :url, false
    change_column_null :news_feeds, :title, false
    change_column_null :news_feeds, :url, false
    change_column_null :news_posts, :body, false
    change_column_null :news_posts, :title, false
    change_column_null :places, :term, false
    change_column_null :series_statements, :original_title, false
    change_column_null :series_statement_merge_lists, :title, false
    change_column_null :subjects, :term, false
    change_column_null :users, :username, false
  end
end

class AddForeignKeyToAgentsReferencingRoles < ActiveRecord::Migration[6.1]
  def change
    [
      :agents,
      :items,
      :manifestations,
      :news_posts,
      :profiles,
      :subjects
    ].each do |table|
      add_foreign_key table, :roles, column: 'required_role_id'
    end
  end
end

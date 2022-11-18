class ChangeColumnAgentsRequiredRoleIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    [
      :agents,
      :items,
      :manifestations,
      :news_posts,
      :profiles,
      :subjects
    ].each do |table|
      change_column table, :required_role_id, :bigint
    end

    change_column :user_has_roles, :role_id, :bigint
  end
end

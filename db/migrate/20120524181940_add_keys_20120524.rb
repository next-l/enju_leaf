class AddKeys20120524 < ActiveRecord::Migration
  def change
    add_foreign_key "baskets", "users", :name => "baskets_user_id_fk", :dependent => :nullify
    add_foreign_key "items", "budget_types", :name => "items_budget_type_id_fk"
    add_foreign_key "items", "shelves", :name => "items_shelf_id_fk"
    add_foreign_key "libraries", "countries", :name => "libraries_country_id_fk"
    add_foreign_key "libraries", "library_groups", :name => "libraries_library_group_id_fk"
    add_foreign_key "library_groups", "countries", :name => "library_groups_country_id_fk"
    add_foreign_key "shelves", "libraries", :name => "shelves_library_id_fk"
    add_foreign_key "user_has_roles", "roles", :name => "user_has_roles_role_id_fk"
    add_foreign_key "user_has_roles", "users", :name => "user_has_roles_user_id_fk", :dependent => :delete
    add_foreign_key "users", "libraries", :name => "users_library_id_fk"
    add_foreign_key "users", "roles", :name => "users_required_role_id_fk", :column => "required_role_id"
    add_foreign_key "users", "user_groups", :name => "users_user_group_id_fk"
  end
end

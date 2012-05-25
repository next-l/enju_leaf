class AddKeys20120525 < ActiveRecord::Migration
  def change
    add_foreign_key "creates", "create_types", :name => "creates_create_type_id_fk"
    add_foreign_key "creates", "patrons", :name => "creates_patron_id_fk"
    add_foreign_key "creates", "manifestations", :name => "creates_work_id_fk", :column => "work_id"
    add_foreign_key "exemplifies", "items", :name => "exemplifies_item_id_fk", :dependent => :delete
    add_foreign_key "exemplifies", "manifestations", :name => "exemplifies_manifestation_id_fk"
    add_foreign_key "items", "bookstores", :name => "items_bookstore_id_fk"
    add_foreign_key "items", "roles", :name => "items_required_role_id_fk", :column => "required_role_id"
    add_foreign_key "manifestations", "carrier_types", :name => "manifestations_carrier_type_id_fk"
    add_foreign_key "manifestations", "content_types", :name => "manifestations_content_type_id_fk"
    add_foreign_key "manifestations", "frequencies", :name => "manifestations_frequency_id_fk"
    add_foreign_key "manifestations", "languages", :name => "manifestations_language_id_fk"
    add_foreign_key "manifestations", "roles", :name => "manifestations_required_role_id_fk", :column => "required_role_id"
    add_foreign_key "owns", "items", :name => "owns_item_id_fk"
    add_foreign_key "owns", "patrons", :name => "owns_patron_id_fk"
    add_foreign_key "patrons", "countries", :name => "patrons_country_id_fk"
    add_foreign_key "patrons", "languages", :name => "patrons_language_id_fk"
    add_foreign_key "patrons", "patron_types", :name => "patrons_patron_type_id_fk"
    add_foreign_key "patrons", "roles", :name => "patrons_required_role_id_fk", :column => "required_role_id"
    add_foreign_key "patrons", "users", :name => "patrons_user_id_fk", :dependent => :delete
    add_foreign_key "produces", "manifestations", :name => "produces_manifestation_id_fk"
    add_foreign_key "produces", "patrons", :name => "produces_patron_id_fk"
    add_foreign_key "produces", "produce_types", :name => "produces_produce_type_id_fk"
    add_foreign_key "realizes", "manifestations", :name => "realizes_expression_id_fk", :column => "expression_id"
    add_foreign_key "realizes", "patrons", :name => "realizes_patron_id_fk"
    add_foreign_key "realizes", "realize_types", :name => "realizes_realize_type_id_fk"
    add_foreign_key "series_has_manifestations", "manifestations", :name => "series_has_manifestations_manifestation_id_fk"
    add_foreign_key "series_has_manifestations", "series_statements", :name => "series_has_manifestations_series_statement_id_fk"
    add_foreign_key "series_statements", "manifestations", :name => "series_statements_root_manifestation_id_fk", :column => "root_manifestation_id"
  end
end

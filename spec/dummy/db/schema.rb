# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140610123439) do

  create_table "accepts", force: true do |t|
    t.integer  "basket_id"
    t.integer  "item_id"
    t.integer  "librarian_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accepts", ["basket_id"], name: "index_accepts_on_basket_id"
  add_index "accepts", ["item_id"], name: "index_accepts_on_item_id"

  create_table "agent_import_files", force: true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "user_id"
    t.text     "note"
    t.datetime "executed_at"
    t.string   "state"
    t.string   "agent_import_file_name"
    t.string   "agent_import_content_type"
    t.integer  "agent_import_file_size"
    t.datetime "agent_import_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "agent_import_fingerprint"
    t.text     "error_message"
    t.string   "edit_mode"
  end

  add_index "agent_import_files", ["parent_id"], name: "index_agent_import_files_on_parent_id"
  add_index "agent_import_files", ["state"], name: "index_agent_import_files_on_state"
  add_index "agent_import_files", ["user_id"], name: "index_agent_import_files_on_user_id"

  create_table "agent_import_results", force: true do |t|
    t.integer  "agent_import_file_id"
    t.integer  "agent_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agent_relationship_types", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agent_relationships", force: true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.integer  "agent_relationship_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "agent_relationships", ["child_id"], name: "index_agent_relationships_on_child_id"
  add_index "agent_relationships", ["parent_id"], name: "index_agent_relationships_on_parent_id"

  create_table "agent_types", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agents", force: true do |t|
    t.integer  "user_id"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "first_name"
    t.string   "last_name_transcription"
    t.string   "middle_name_transcription"
    t.string   "first_name_transcription"
    t.string   "corporate_name"
    t.string   "corporate_name_transcription"
    t.string   "full_name"
    t.text     "full_name_transcription"
    t.text     "full_name_alternative"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "zip_code_1"
    t.string   "zip_code_2"
    t.text     "address_1"
    t.text     "address_2"
    t.text     "address_1_note"
    t.text     "address_2_note"
    t.string   "telephone_number_1"
    t.string   "telephone_number_2"
    t.string   "fax_number_1"
    t.string   "fax_number_2"
    t.text     "other_designation"
    t.text     "place"
    t.string   "postal_code"
    t.text     "street"
    t.text     "locality"
    t.text     "region"
    t.datetime "date_of_birth"
    t.datetime "date_of_death"
    t.integer  "language_id",                         default: 1, null: false
    t.integer  "country_id",                          default: 1, null: false
    t.integer  "agent_type_id",                       default: 1, null: false
    t.integer  "lock_version",                        default: 0, null: false
    t.text     "note"
    t.integer  "required_role_id",                    default: 1, null: false
    t.integer  "required_score",                      default: 0, null: false
    t.string   "state"
    t.text     "email"
    t.text     "url"
    t.text     "full_name_alternative_transcription"
    t.string   "birth_date"
    t.string   "death_date"
    t.string   "agent_identifier"
  end

  add_index "agents", ["agent_identifier"], name: "index_agents_on_agent_identifier"
  add_index "agents", ["country_id"], name: "index_agents_on_country_id"
  add_index "agents", ["full_name"], name: "index_agents_on_full_name"
  add_index "agents", ["language_id"], name: "index_agents_on_language_id"
  add_index "agents", ["required_role_id"], name: "index_agents_on_required_role_id"
  add_index "agents", ["user_id"], name: "index_agents_on_user_id", unique: true

  create_table "baskets", force: true do |t|
    t.integer  "user_id"
    t.text     "note"
    t.integer  "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "baskets", ["user_id"], name: "index_baskets_on_user_id"

  create_table "bookstores", force: true do |t|
    t.text     "name",             null: false
    t.string   "zip_code"
    t.text     "address"
    t.text     "note"
    t.string   "telephone_number"
    t.string   "fax_number"
    t.string   "url"
    t.integer  "position"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "budget_types", force: true do |t|
    t.string   "name"
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carrier_types", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_types", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string  "name",         null: false
    t.text    "display_name"
    t.string  "alpha_2"
    t.string  "alpha_3"
    t.string  "numeric_3"
    t.text    "note"
    t.integer "position"
  end

  add_index "countries", ["alpha_2"], name: "index_countries_on_alpha_2"
  add_index "countries", ["alpha_3"], name: "index_countries_on_alpha_3"
  add_index "countries", ["name"], name: "index_countries_on_name"
  add_index "countries", ["numeric_3"], name: "index_countries_on_numeric_3"

  create_table "create_types", force: true do |t|
    t.string   "name"
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "creates", force: true do |t|
    t.integer  "agent_id",       null: false
    t.integer  "work_id",        null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "create_type_id"
  end

  add_index "creates", ["agent_id"], name: "index_creates_on_agent_id"
  add_index "creates", ["work_id"], name: "index_creates_on_work_id"

  create_table "donates", force: true do |t|
    t.integer  "agent_id",   null: false
    t.integer  "item_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "donates", ["agent_id"], name: "index_donates_on_agent_id"
  add_index "donates", ["item_id"], name: "index_donates_on_item_id"

  create_table "exemplifies", force: true do |t|
    t.integer  "manifestation_id", null: false
    t.integer  "item_id",          null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exemplifies", ["item_id"], name: "index_exemplifies_on_item_id", unique: true
  add_index "exemplifies", ["manifestation_id"], name: "index_exemplifies_on_manifestation_id"

  create_table "extents", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "form_of_works", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "frequencies", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_requests", force: true do |t|
    t.string   "isbn"
    t.string   "state"
    t.integer  "manifestation_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "import_requests", ["isbn"], name: "index_import_requests_on_isbn"
  add_index "import_requests", ["manifestation_id"], name: "index_import_requests_on_manifestation_id"
  add_index "import_requests", ["user_id"], name: "index_import_requests_on_user_id"

  create_table "items", force: true do |t|
    t.string   "call_number"
    t.string   "item_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "shelf_id",              default: 1,     null: false
    t.boolean  "include_supplements",   default: false, null: false
    t.text     "note"
    t.string   "url"
    t.integer  "price"
    t.integer  "lock_version",          default: 0,     null: false
    t.integer  "required_role_id",      default: 1,     null: false
    t.string   "state"
    t.integer  "required_score",        default: 0,     null: false
    t.datetime "acquired_at"
    t.integer  "bookstore_id"
    t.integer  "budget_type_id"
    t.integer  "manifestation_id"
    t.integer  "circulation_status_id", default: 5,     null: false
    t.integer  "checkout_type_id",      default: 1,     null: false
  end

  add_index "items", ["bookstore_id"], name: "index_items_on_bookstore_id"
  add_index "items", ["checkout_type_id"], name: "index_items_on_checkout_type_id"
  add_index "items", ["circulation_status_id"], name: "index_items_on_circulation_status_id"
  add_index "items", ["item_identifier"], name: "index_items_on_item_identifier"
  add_index "items", ["required_role_id"], name: "index_items_on_required_role_id"
  add_index "items", ["shelf_id"], name: "index_items_on_shelf_id"

  create_table "languages", force: true do |t|
    t.string  "name",         null: false
    t.string  "native_name"
    t.text    "display_name"
    t.string  "iso_639_1"
    t.string  "iso_639_2"
    t.string  "iso_639_3"
    t.text    "note"
    t.integer "position"
  end

  add_index "languages", ["iso_639_1"], name: "index_languages_on_iso_639_1"
  add_index "languages", ["iso_639_2"], name: "index_languages_on_iso_639_2"
  add_index "languages", ["iso_639_3"], name: "index_languages_on_iso_639_3"
  add_index "languages", ["name"], name: "index_languages_on_name", unique: true

  create_table "libraries", force: true do |t|
    t.string   "name",                                null: false
    t.text     "display_name"
    t.string   "short_display_name",                  null: false
    t.string   "zip_code"
    t.text     "street"
    t.text     "locality"
    t.text     "region"
    t.string   "telephone_number_1"
    t.string   "telephone_number_2"
    t.string   "fax_number"
    t.text     "note"
    t.integer  "call_number_rows",      default: 1,   null: false
    t.string   "call_number_delimiter", default: "|", null: false
    t.integer  "library_group_id",      default: 1,   null: false
    t.integer  "users_count",           default: 0,   null: false
    t.integer  "position"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "isil"
  end

  add_index "libraries", ["library_group_id"], name: "index_libraries_on_library_group_id"
  add_index "libraries", ["name"], name: "index_libraries_on_name", unique: true

  create_table "library_groups", force: true do |t|
    t.string   "name",                                                         null: false
    t.text     "display_name"
    t.string   "short_name",                                                   null: false
    t.string   "email"
    t.text     "my_networks"
    t.text     "login_banner"
    t.text     "note"
    t.integer  "valid_period_for_new_user", default: 365,                      null: false
    t.integer  "country_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "admin_networks"
    t.string   "url",                       default: "http://localhost:3000/"
  end

  add_index "library_groups", ["short_name"], name: "index_library_groups_on_short_name"

  create_table "licenses", force: true do |t|
    t.string   "name",         null: false
    t.string   "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manifestation_relationship_types", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manifestation_relationships", force: true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.integer  "manifestation_relationship_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "manifestation_relationships", ["child_id"], name: "index_manifestation_relationships_on_child_id"
  add_index "manifestation_relationships", ["parent_id"], name: "index_manifestation_relationships_on_parent_id"

  create_table "manifestations", force: true do |t|
    t.text     "original_title",                                  null: false
    t.text     "title_alternative"
    t.text     "title_transcription"
    t.string   "classification_number"
    t.string   "manifestation_identifier"
    t.datetime "date_of_publication"
    t.datetime "date_copyrighted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "access_address"
    t.integer  "language_id",                     default: 1,     null: false
    t.integer  "carrier_type_id",                 default: 1,     null: false
    t.integer  "extent_id",                       default: 1,     null: false
    t.integer  "start_page"
    t.integer  "end_page"
    t.integer  "height"
    t.integer  "width"
    t.integer  "depth"
    t.string   "isbn"
    t.string   "isbn10"
    t.string   "wrong_isbn"
    t.string   "nbn"
    t.string   "lccn"
    t.string   "oclc_number"
    t.string   "issn"
    t.integer  "price"
    t.text     "fulltext"
    t.string   "volume_number_string"
    t.string   "issue_number_string"
    t.string   "serial_number_string"
    t.integer  "edition"
    t.text     "note"
    t.boolean  "repository_content",              default: false, null: false
    t.integer  "lock_version",                    default: 0,     null: false
    t.integer  "required_role_id",                default: 1,     null: false
    t.string   "state"
    t.integer  "required_score",                  default: 0,     null: false
    t.integer  "frequency_id",                    default: 1,     null: false
    t.boolean  "subscription_master",             default: false, null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.text     "title_alternative_transcription"
    t.text     "description"
    t.text     "abstract"
    t.datetime "available_at"
    t.datetime "valid_until"
    t.datetime "date_submitted"
    t.datetime "date_accepted"
    t.datetime "date_caputured"
    t.string   "pub_date"
    t.string   "edition_string"
    t.integer  "volume_number"
    t.integer  "issue_number"
    t.integer  "serial_number"
    t.string   "ndc"
    t.integer  "content_type_id",                 default: 1
    t.integer  "year_of_publication"
    t.text     "attachment_meta"
    t.integer  "month_of_publication"
    t.boolean  "fulltext_content"
    t.string   "doi"
  end

  add_index "manifestations", ["access_address"], name: "index_manifestations_on_access_address"
  add_index "manifestations", ["doi"], name: "index_manifestations_on_doi"
  add_index "manifestations", ["isbn"], name: "index_manifestations_on_isbn"
  add_index "manifestations", ["issn"], name: "index_manifestations_on_issn"
  add_index "manifestations", ["lccn"], name: "index_manifestations_on_lccn"
  add_index "manifestations", ["manifestation_identifier"], name: "index_manifestations_on_manifestation_identifier"
  add_index "manifestations", ["nbn"], name: "index_manifestations_on_nbn"
  add_index "manifestations", ["oclc_number"], name: "index_manifestations_on_oclc_number"
  add_index "manifestations", ["updated_at"], name: "index_manifestations_on_updated_at"

  create_table "medium_of_performances", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "owns", force: true do |t|
    t.integer  "agent_id",   null: false
    t.integer  "item_id",    null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "owns", ["agent_id"], name: "index_owns_on_agent_id"
  add_index "owns", ["item_id"], name: "index_owns_on_item_id"

  create_table "picture_files", force: true do |t|
    t.integer  "picture_attachable_id"
    t.string   "picture_attachable_type"
    t.string   "content_type"
    t.text     "title"
    t.string   "thumbnail"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.text     "picture_meta"
    t.string   "picture_fingerprint"
  end

  add_index "picture_files", ["picture_attachable_id", "picture_attachable_type"], name: "index_picture_files_on_picture_attachable_id_and_type"

  create_table "produce_types", force: true do |t|
    t.string   "name"
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "produces", force: true do |t|
    t.integer  "agent_id",         null: false
    t.integer  "manifestation_id", null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "produce_type_id"
  end

  add_index "produces", ["agent_id"], name: "index_produces_on_agent_id"
  add_index "produces", ["manifestation_id"], name: "index_produces_on_manifestation_id"

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.integer  "user_group_id"
    t.integer  "library_id"
    t.string   "locale"
    t.string   "user_number"
    t.text     "full_name"
    t.text     "note"
    t.text     "keyword_list"
    t.integer  "required_role_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id"
  add_index "profiles", ["user_number"], name: "index_profiles_on_user_number"

  create_table "realize_types", force: true do |t|
    t.string   "name"
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "realizes", force: true do |t|
    t.integer  "agent_id",        null: false
    t.integer  "expression_id",   null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "realize_type_id"
  end

  add_index "realizes", ["agent_id"], name: "index_realizes_on_agent_id"
  add_index "realizes", ["expression_id"], name: "index_realizes_on_expression_id"

  create_table "request_status_types", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_types", force: true do |t|
    t.string   "name",         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_import_files", force: true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "user_id"
    t.text     "note"
    t.datetime "executed_at"
    t.string   "state"
    t.string   "resource_import_file_name"
    t.string   "resource_import_content_type"
    t.integer  "resource_import_file_size"
    t.datetime "resource_import_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "edit_mode"
    t.string   "resource_import_fingerprint"
    t.text     "error_message"
  end

  add_index "resource_import_files", ["parent_id"], name: "index_resource_import_files_on_parent_id"
  add_index "resource_import_files", ["state"], name: "index_resource_import_files_on_state"
  add_index "resource_import_files", ["user_id"], name: "index_resource_import_files_on_user_id"

  create_table "resource_import_results", force: true do |t|
    t.integer  "resource_import_file_id"
    t.integer  "manifestation_id"
    t.integer  "item_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resource_import_results", ["item_id"], name: "index_resource_import_results_on_item_id"
  add_index "resource_import_results", ["manifestation_id"], name: "index_resource_import_results_on_manifestation_id"
  add_index "resource_import_results", ["resource_import_file_id"], name: "index_resource_import_results_on_resource_import_file_id"

  create_table "roles", force: true do |t|
    t.string   "name",                     null: false
    t.string   "display_name"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",        default: 0, null: false
    t.integer  "position"
  end

  create_table "search_engines", force: true do |t|
    t.string   "name",             null: false
    t.text     "display_name"
    t.string   "url",              null: false
    t.text     "base_url",         null: false
    t.text     "http_method",      null: false
    t.text     "query_param",      null: false
    t.text     "additional_param"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series_has_manifestations", force: true do |t|
    t.integer  "series_statement_id"
    t.integer  "manifestation_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "series_has_manifestations", ["manifestation_id"], name: "index_series_has_manifestations_on_manifestation_id"
  add_index "series_has_manifestations", ["series_statement_id"], name: "index_series_has_manifestations_on_series_statement_id"

  create_table "series_statement_relationships", force: true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series_statements", force: true do |t|
    t.text     "original_title"
    t.text     "numbering"
    t.text     "title_subseries"
    t.text     "numbering_subseries"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title_transcription"
    t.text     "title_alternative"
    t.string   "series_statement_identifier"
    t.string   "issn"
    t.boolean  "periodical",                    default: false, null: false
    t.integer  "manifestation_id"
    t.text     "note"
    t.text     "title_subseries_transcription"
  end

  add_index "series_statements", ["manifestation_id"], name: "index_series_statements_on_manifestation_id"
  add_index "series_statements", ["series_statement_identifier"], name: "index_series_statements_on_series_statement_identifier"

  create_table "shelves", force: true do |t|
    t.string   "name",                         null: false
    t.text     "display_name"
    t.text     "note"
    t.integer  "library_id",   default: 1,     null: false
    t.integer  "items_count",  default: 0,     null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "closed",       default: false, null: false
  end

  add_index "shelves", ["library_id"], name: "index_shelves_on_library_id"

  create_table "subscribes", force: true do |t|
    t.integer  "subscription_id", null: false
    t.integer  "work_id",         null: false
    t.datetime "start_at",        null: false
    t.datetime "end_at",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscribes", ["subscription_id"], name: "index_subscribes_on_subscription_id"
  add_index "subscribes", ["work_id"], name: "index_subscribes_on_work_id"

  create_table "subscriptions", force: true do |t|
    t.text     "title",                        null: false
    t.text     "note"
    t.integer  "user_id"
    t.integer  "order_list_id"
    t.datetime "deleted_at"
    t.integer  "subscribes_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["order_list_id"], name: "index_subscriptions_on_order_list_id"
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id"

  create_table "user_groups", force: true do |t|
    t.string   "name"
    t.text     "display_name"
    t.text     "note"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "valid_period_for_new_user",        default: 0, null: false
    t.datetime "expired_at"
    t.integer  "number_of_day_to_notify_overdue",  default: 1, null: false
    t.integer  "number_of_day_to_notify_due_date", default: 7, null: false
    t.integer  "number_of_time_to_notify_overdue", default: 3, null: false
  end

  create_table "user_has_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_has_roles", ["role_id"], name: "index_user_has_roles_on_role_id"
  add_index "user_has_roles", ["user_id"], name: "index_user_has_roles_on_user_id"

  create_table "user_import_file_transitions", force: true do |t|
    t.string   "to_state"
    t.text     "metadata",            default: "{}"
    t.integer  "sort_key"
    t.integer  "user_import_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_import_file_transitions", ["sort_key", "user_import_file_id"], name: "index_user_import_file_transitions_on_sort_key_and_file_id", unique: true
  add_index "user_import_file_transitions", ["user_import_file_id"], name: "index_user_import_file_transitions_on_user_import_file_id"

  create_table "user_import_files", force: true do |t|
    t.integer  "user_id"
    t.text     "note"
    t.datetime "executed_at"
    t.string   "state"
    t.string   "user_import_file_name"
    t.string   "user_import_content_type"
    t.string   "user_import_file_size"
    t.datetime "user_import_updated_at"
    t.string   "user_import_fingerprint"
    t.string   "edit_mode"
    t.text     "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_import_results", force: true do |t|
    t.integer  "user_import_file_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "user_number"
    t.string   "state"
    t.string   "locale"
    t.datetime "deleted_at"
    t.datetime "expired_at"
    t.integer  "library_id",             default: 1,  null: false
    t.integer  "required_role_id",       default: 1,  null: false
    t.integer  "user_group_id",          default: 1,  null: false
    t.text     "note"
    t.text     "keyword_list"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "confirmed_at"
  end

  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  add_index "users", ["user_group_id"], name: "index_users_on_user_group_id"
  add_index "users", ["user_number"], name: "index_users_on_user_number", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end

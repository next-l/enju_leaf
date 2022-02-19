# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_25_090703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accepts", id: :serial, force: :cascade do |t|
    t.integer "basket_id"
    t.integer "item_id"
    t.integer "librarian_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["basket_id"], name: "index_accepts_on_basket_id"
    t.index ["item_id"], name: "index_accepts_on_item_id"
    t.index ["librarian_id"], name: "index_accepts_on_librarian_id"
  end

  create_table "agent_import_file_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "agent_import_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["agent_import_file_id", "most_recent"], name: "index_agent_import_file_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["agent_import_file_id"], name: "index_agent_import_file_transitions_on_agent_import_file_id"
    t.index ["sort_key", "agent_import_file_id"], name: "index_agent_import_file_transitions_on_sort_key_and_file_id", unique: true
  end

  create_table "agent_import_files", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.string "content_type"
    t.integer "size"
    t.integer "user_id"
    t.text "note"
    t.datetime "executed_at"
    t.string "agent_import_file_name"
    t.string "agent_import_content_type"
    t.integer "agent_import_file_size"
    t.datetime "agent_import_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "agent_import_fingerprint"
    t.text "error_message"
    t.string "edit_mode"
    t.string "user_encoding"
    t.index ["parent_id"], name: "index_agent_import_files_on_parent_id"
    t.index ["user_id"], name: "index_agent_import_files_on_user_id"
  end

  create_table "agent_import_results", id: :serial, force: :cascade do |t|
    t.integer "agent_import_file_id"
    t.integer "agent_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agent_merge_lists", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agent_merges", id: :serial, force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "agent_merge_list_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["agent_id"], name: "index_agent_merges_on_agent_id"
    t.index ["agent_merge_list_id"], name: "index_agent_merges_on_agent_merge_list_id"
  end

  create_table "agent_relationship_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agent_relationships", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.integer "child_id"
    t.integer "agent_relationship_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.index ["child_id"], name: "index_agent_relationships_on_child_id"
    t.index ["parent_id"], name: "index_agent_relationships_on_parent_id"
  end

  create_table "agent_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agents", id: :serial, force: :cascade do |t|
    t.string "last_name"
    t.string "middle_name"
    t.string "first_name"
    t.string "last_name_transcription"
    t.string "middle_name_transcription"
    t.string "first_name_transcription"
    t.string "corporate_name"
    t.string "corporate_name_transcription"
    t.string "full_name"
    t.text "full_name_transcription"
    t.text "full_name_alternative"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "zip_code_1"
    t.string "zip_code_2"
    t.text "address_1"
    t.text "address_2"
    t.text "address_1_note"
    t.text "address_2_note"
    t.string "telephone_number_1"
    t.string "telephone_number_2"
    t.string "fax_number_1"
    t.string "fax_number_2"
    t.text "other_designation"
    t.text "place"
    t.string "postal_code"
    t.text "street"
    t.text "locality"
    t.text "region"
    t.datetime "date_of_birth"
    t.datetime "date_of_death"
    t.integer "language_id", default: 1, null: false
    t.integer "country_id", default: 1, null: false
    t.integer "agent_type_id", default: 1, null: false
    t.integer "lock_version", default: 0, null: false
    t.text "note"
    t.integer "required_role_id", default: 1, null: false
    t.integer "required_score", default: 0, null: false
    t.text "email"
    t.text "url"
    t.text "full_name_alternative_transcription"
    t.string "birth_date"
    t.string "death_date"
    t.string "agent_identifier"
    t.integer "profile_id"
    t.index ["agent_identifier"], name: "index_agents_on_agent_identifier"
    t.index ["country_id"], name: "index_agents_on_country_id"
    t.index ["full_name"], name: "index_agents_on_full_name"
    t.index ["language_id"], name: "index_agents_on_language_id"
    t.index ["profile_id"], name: "index_agents_on_profile_id"
    t.index ["required_role_id"], name: "index_agents_on_required_role_id"
  end

  create_table "answer_has_items", id: :serial, force: :cascade do |t|
    t.integer "answer_id"
    t.integer "item_id"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["answer_id"], name: "index_answer_has_items_on_answer_id"
    t.index ["item_id"], name: "index_answer_has_items_on_item_id"
  end

  create_table "answers", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "question_id", null: false
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean "shared", default: true, null: false
    t.string "state"
    t.text "item_identifier_list"
    t.text "url_list"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "baskets", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "note"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_baskets_on_user_id"
  end

  create_table "bookmark_stat_has_manifestations", id: :serial, force: :cascade do |t|
    t.integer "bookmark_stat_id", null: false
    t.integer "manifestation_id", null: false
    t.integer "bookmarks_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bookmark_stat_id"], name: "index_bookmark_stat_has_manifestations_on_bookmark_stat_id"
    t.index ["manifestation_id"], name: "index_bookmark_stat_has_manifestations_on_manifestation_id"
  end

  create_table "bookmark_stat_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "bookmark_stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["bookmark_stat_id", "most_recent"], name: "index_bookmark_stat_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["bookmark_stat_id"], name: "index_bookmark_stat_transitions_on_bookmark_stat_id"
    t.index ["sort_key", "bookmark_stat_id"], name: "index_bookmark_stat_transitions_on_sort_key_and_stat_id", unique: true
  end

  create_table "bookmark_stats", id: :serial, force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "manifestation_id"
    t.text "title"
    t.string "url"
    t.text "note"
    t.boolean "shared"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["manifestation_id"], name: "index_bookmarks_on_manifestation_id"
    t.index ["url"], name: "index_bookmarks_on_url"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "bookstores", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.string "zip_code"
    t.text "address"
    t.text "note"
    t.string "telephone_number"
    t.string "fax_number"
    t.string "url"
    t.integer "position"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "budget_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carrier_type_has_checkout_types", id: :serial, force: :cascade do |t|
    t.integer "carrier_type_id", null: false
    t.integer "checkout_type_id", null: false
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["carrier_type_id"], name: "index_carrier_type_has_checkout_types_on_m_form_id"
    t.index ["checkout_type_id"], name: "index_carrier_type_has_checkout_types_on_checkout_type_id"
  end

  create_table "carrier_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.bigint "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "checked_items", id: :serial, force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "basket_id", null: false
    t.integer "librarian_id"
    t.datetime "due_date", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["basket_id"], name: "index_checked_items_on_basket_id"
    t.index ["item_id"], name: "index_checked_items_on_item_id"
    t.index ["librarian_id"], name: "index_checked_items_on_librarian_id"
    t.index ["user_id"], name: "index_checked_items_on_user_id"
  end

  create_table "checkins", id: :serial, force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "librarian_id"
    t.integer "basket_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "lock_version", default: 0, null: false
    t.index ["basket_id"], name: "index_checkins_on_basket_id"
    t.index ["item_id"], name: "index_checkins_on_item_id"
    t.index ["librarian_id"], name: "index_checkins_on_librarian_id"
  end

  create_table "checkout_stat_has_manifestations", id: :serial, force: :cascade do |t|
    t.integer "manifestation_checkout_stat_id", null: false
    t.integer "manifestation_id", null: false
    t.integer "checkouts_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["manifestation_checkout_stat_id"], name: "index_checkout_stat_has_manifestations_on_checkout_stat_id"
    t.index ["manifestation_id"], name: "index_checkout_stat_has_manifestations_on_manifestation_id"
  end

  create_table "checkout_stat_has_users", id: :serial, force: :cascade do |t|
    t.integer "user_checkout_stat_id", null: false
    t.integer "user_id", null: false
    t.integer "checkouts_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_checkout_stat_id"], name: "index_checkout_stat_has_users_on_user_checkout_stat_id"
    t.index ["user_id"], name: "index_checkout_stat_has_users_on_user_id"
  end

  create_table "checkout_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_checkout_types_on_name"
  end

  create_table "checkouts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id", null: false
    t.integer "checkin_id"
    t.integer "librarian_id"
    t.integer "basket_id"
    t.datetime "due_date"
    t.integer "checkout_renewal_count", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "shelf_id"
    t.integer "library_id"
    t.index ["basket_id"], name: "index_checkouts_on_basket_id"
    t.index ["checkin_id"], name: "index_checkouts_on_checkin_id"
    t.index ["item_id", "basket_id"], name: "index_checkouts_on_item_id_and_basket_id", unique: true
    t.index ["item_id"], name: "index_checkouts_on_item_id"
    t.index ["librarian_id"], name: "index_checkouts_on_librarian_id"
    t.index ["library_id"], name: "index_checkouts_on_library_id"
    t.index ["shelf_id"], name: "index_checkouts_on_shelf_id"
    t.index ["user_id"], name: "index_checkouts_on_user_id"
  end

  create_table "circulation_statuses", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classification_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classifications", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.string "category", null: false
    t.text "note"
    t.integer "classification_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "lft"
    t.integer "rgt"
    t.integer "manifestation_id"
    t.string "url"
    t.string "label"
    t.index ["category"], name: "index_classifications_on_category"
    t.index ["classification_type_id"], name: "index_classifications_on_classification_type_id"
    t.index ["manifestation_id"], name: "index_classifications_on_manifestation_id"
    t.index ["parent_id"], name: "index_classifications_on_parent_id"
  end

  create_table "colors", id: :serial, force: :cascade do |t|
    t.integer "library_group_id"
    t.string "property"
    t.string "code"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["library_group_id"], name: "index_colors_on_library_group_id"
  end

  create_table "content_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.string "alpha_2"
    t.string "alpha_3"
    t.string "numeric_3"
    t.text "note"
    t.integer "position"
    t.index ["alpha_2"], name: "index_countries_on_alpha_2"
    t.index ["alpha_3"], name: "index_countries_on_alpha_3"
    t.index ["name"], name: "index_countries_on_name"
    t.index ["numeric_3"], name: "index_countries_on_numeric_3"
  end

  create_table "create_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "creates", id: :serial, force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "work_id", null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "create_type_id"
    t.index ["agent_id"], name: "index_creates_on_agent_id"
    t.index ["work_id"], name: "index_creates_on_work_id"
  end

  create_table "demands", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "item_id"
    t.integer "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_demands_on_item_id"
    t.index ["message_id"], name: "index_demands_on_message_id"
    t.index ["user_id"], name: "index_demands_on_user_id"
  end

  create_table "donates", id: :serial, force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "item_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["agent_id"], name: "index_donates_on_agent_id"
    t.index ["item_id"], name: "index_donates_on_item_id"
  end

  create_table "event_categories", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_export_file_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "event_export_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["event_export_file_id", "most_recent"], name: "index_event_export_file_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["event_export_file_id"], name: "index_event_export_file_transitions_on_file_id"
    t.index ["sort_key", "event_export_file_id"], name: "index_event_export_file_transitions_on_sort_key_and_file_id", unique: true
  end

  create_table "event_export_files", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "event_export_file_name"
    t.string "event_export_content_type"
    t.bigint "event_export_file_size"
    t.datetime "event_export_updated_at"
    t.datetime "executed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_event_export_files_on_user_id"
  end

  create_table "event_import_file_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "event_import_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["event_import_file_id", "most_recent"], name: "index_event_import_file_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["event_import_file_id"], name: "index_event_import_file_transitions_on_event_import_file_id"
    t.index ["sort_key", "event_import_file_id"], name: "index_event_import_file_transitions_on_sort_key_and_file_id", unique: true
  end

  create_table "event_import_files", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.string "content_type"
    t.integer "size"
    t.integer "user_id"
    t.text "note"
    t.datetime "executed_at"
    t.string "event_import_file_name"
    t.string "event_import_content_type"
    t.integer "event_import_file_size"
    t.datetime "event_import_updated_at"
    t.string "edit_mode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "event_import_fingerprint"
    t.text "error_message"
    t.string "user_encoding"
    t.integer "default_library_id"
    t.integer "default_event_category_id"
    t.index ["parent_id"], name: "index_event_import_files_on_parent_id"
    t.index ["user_id"], name: "index_event_import_files_on_user_id"
  end

  create_table "event_import_results", id: :serial, force: :cascade do |t|
    t.integer "event_import_file_id"
    t.integer "event_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.integer "library_id", null: false
    t.integer "event_category_id", null: false
    t.string "name"
    t.text "note"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "all_day", default: false, null: false
    t.datetime "deleted_at"
    t.text "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "place_id"
    t.index ["event_category_id"], name: "index_events_on_event_category_id"
    t.index ["library_id"], name: "index_events_on_library_id"
    t.index ["place_id"], name: "index_events_on_place_id"
  end

  create_table "form_of_works", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "frequencies", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identifier_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identifiers", id: :serial, force: :cascade do |t|
    t.string "body", null: false
    t.integer "identifier_type_id", null: false
    t.integer "manifestation_id"
    t.boolean "primary"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["body", "identifier_type_id"], name: "index_identifiers_on_body_and_identifier_type_id"
    t.index ["manifestation_id"], name: "index_identifiers_on_manifestation_id"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["name"], name: "index_identities_on_name"
    t.index ["profile_id"], name: "index_identities_on_profile_id"
  end

  create_table "import_request_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "import_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["import_request_id", "most_recent"], name: "index_import_request_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["import_request_id"], name: "index_import_request_transitions_on_import_request_id"
    t.index ["sort_key", "import_request_id"], name: "index_import_request_transitions_on_sort_key_and_request_id", unique: true
  end

  create_table "import_requests", id: :serial, force: :cascade do |t|
    t.string "isbn"
    t.integer "manifestation_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["isbn"], name: "index_import_requests_on_isbn"
    t.index ["manifestation_id"], name: "index_import_requests_on_manifestation_id"
    t.index ["user_id"], name: "index_import_requests_on_user_id"
  end

  create_table "inventories", id: :serial, force: :cascade do |t|
    t.integer "item_id"
    t.integer "inventory_file_id"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "item_identifier"
    t.string "current_shelf_name"
    t.index ["current_shelf_name"], name: "index_inventories_on_current_shelf_name"
    t.index ["inventory_file_id"], name: "index_inventories_on_inventory_file_id"
    t.index ["item_id"], name: "index_inventories_on_item_id"
    t.index ["item_identifier"], name: "index_inventories_on_item_identifier"
  end

  create_table "inventory_files", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.string "content_type"
    t.integer "size"
    t.integer "user_id"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "inventory_file_name"
    t.string "inventory_content_type"
    t.integer "inventory_file_size"
    t.datetime "inventory_updated_at"
    t.string "inventory_fingerprint"
    t.bigint "shelf_id"
    t.index ["shelf_id"], name: "index_inventory_files_on_shelf_id"
    t.index ["user_id"], name: "index_inventory_files_on_user_id"
  end

  create_table "item_custom_properties", force: :cascade do |t|
    t.string "name", null: false, comment: "ラベル名"
    t.text "display_name", null: false, comment: "表示名"
    t.text "note", comment: "備考"
    t.integer "position", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_item_custom_properties_on_name", unique: true
  end

  create_table "item_custom_values", force: :cascade do |t|
    t.bigint "item_custom_property_id", null: false
    t.bigint "item_id", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_custom_property_id", "item_id"], name: "index_item_custom_values_on_custom_item_property_and_item_id", unique: true
    t.index ["item_custom_property_id"], name: "index_item_custom_values_on_custom_property_id"
    t.index ["item_id"], name: "index_item_custom_values_on_item_id"
  end

  create_table "item_has_use_restrictions", id: :serial, force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "use_restriction_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id"], name: "index_item_has_use_restrictions_on_item_id"
    t.index ["use_restriction_id"], name: "index_item_has_use_restrictions_on_use_restriction_id"
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.string "call_number"
    t.string "item_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer "shelf_id", default: 1, null: false
    t.boolean "include_supplements", default: false, null: false
    t.text "note"
    t.string "url"
    t.integer "price"
    t.integer "lock_version", default: 0, null: false
    t.integer "required_role_id", default: 1, null: false
    t.integer "required_score", default: 0, null: false
    t.datetime "acquired_at"
    t.integer "bookstore_id"
    t.integer "budget_type_id"
    t.integer "circulation_status_id", default: 5, null: false
    t.integer "checkout_type_id", default: 1, null: false
    t.string "binding_item_identifier"
    t.string "binding_call_number"
    t.datetime "binded_at"
    t.integer "manifestation_id", null: false
    t.text "memo"
    t.date "missing_since"
    t.index ["binding_item_identifier"], name: "index_items_on_binding_item_identifier"
    t.index ["bookstore_id"], name: "index_items_on_bookstore_id"
    t.index ["checkout_type_id"], name: "index_items_on_checkout_type_id"
    t.index ["circulation_status_id"], name: "index_items_on_circulation_status_id"
    t.index ["item_identifier"], name: "index_items_on_item_identifier"
    t.index ["manifestation_id"], name: "index_items_on_manifestation_id"
    t.index ["required_role_id"], name: "index_items_on_required_role_id"
    t.index ["shelf_id"], name: "index_items_on_shelf_id"
  end

  create_table "jpno_records", force: :cascade do |t|
    t.string "body", null: false
    t.bigint "manifestation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_jpno_records_on_body", unique: true
    t.index ["manifestation_id"], name: "index_jpno_records_on_manifestation_id"
  end

  create_table "languages", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "native_name"
    t.text "display_name"
    t.string "iso_639_1"
    t.string "iso_639_2"
    t.string "iso_639_3"
    t.text "note"
    t.integer "position"
    t.index ["iso_639_1"], name: "index_languages_on_iso_639_1"
    t.index ["iso_639_2"], name: "index_languages_on_iso_639_2"
    t.index ["iso_639_3"], name: "index_languages_on_iso_639_3"
    t.index ["name"], name: "index_languages_on_name", unique: true
  end

  create_table "lending_policies", id: :serial, force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "user_group_id", null: false
    t.integer "loan_period", default: 0, null: false
    t.datetime "fixed_due_date"
    t.integer "renewal", default: 0, null: false
    t.integer "fine", default: 0, null: false
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id", "user_group_id"], name: "index_lending_policies_on_item_id_and_user_group_id", unique: true
  end

  create_table "libraries", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.string "short_display_name", null: false
    t.string "zip_code"
    t.text "street"
    t.text "locality"
    t.text "region"
    t.string "telephone_number_1"
    t.string "telephone_number_2"
    t.string "fax_number"
    t.text "note"
    t.integer "call_number_rows", default: 1, null: false
    t.string "call_number_delimiter", default: "|", null: false
    t.integer "library_group_id", null: false
    t.integer "users_count", default: 0, null: false
    t.integer "position"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.text "opening_hour"
    t.string "isil"
    t.float "latitude"
    t.float "longitude"
    t.index ["library_group_id"], name: "index_libraries_on_library_group_id"
    t.index ["name"], name: "index_libraries_on_name"
  end

  create_table "library_group_translations", force: :cascade do |t|
    t.integer "library_group_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "login_banner"
    t.text "footer_banner"
    t.index ["library_group_id"], name: "index_library_group_translations_on_library_group_id"
    t.index ["locale"], name: "index_library_group_translations_on_locale"
  end

  create_table "library_groups", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.string "short_name", null: false
    t.text "my_networks"
    t.text "old_login_banner"
    t.text "note"
    t.integer "country_id"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "admin_networks"
    t.boolean "allow_bookmark_external_url", default: false, null: false
    t.string "url", default: "http://localhost:3000/"
    t.text "settings"
    t.text "html_snippet"
    t.string "book_jacket_source"
    t.integer "max_number_of_results", default: 1000
    t.boolean "family_name_first", default: true
    t.string "screenshot_generator"
    t.integer "pub_year_facet_range_interval", default: 10
    t.integer "user_id"
    t.boolean "csv_charset_conversion", default: false, null: false
    t.string "header_logo_file_name"
    t.string "header_logo_content_type"
    t.bigint "header_logo_file_size"
    t.datetime "header_logo_updated_at"
    t.text "header_logo_meta"
    t.index ["short_name"], name: "index_library_groups_on_short_name"
    t.index ["user_id"], name: "index_library_groups_on_user_id"
  end

  create_table "licenses", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manifestation_checkout_stat_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "manifestation_checkout_stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["manifestation_checkout_stat_id", "most_recent"], name: "index_manifestation_checkout_stat_transitions_parent_most_rece", unique: true, where: "most_recent"
    t.index ["manifestation_checkout_stat_id"], name: "index_manifestation_checkout_stat_transitions_on_stat_id"
    t.index ["sort_key", "manifestation_checkout_stat_id"], name: "index_manifestation_checkout_stat_transitions_on_transition", unique: true
  end

  create_table "manifestation_checkout_stats", id: :serial, force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_manifestation_checkout_stats_on_user_id"
  end

  create_table "manifestation_custom_properties", force: :cascade do |t|
    t.string "name", null: false, comment: "ラベル名"
    t.text "display_name", null: false, comment: "表示名"
    t.text "note", comment: "備考"
    t.integer "position", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_manifestation_custom_properties_on_name", unique: true
  end

  create_table "manifestation_custom_values", force: :cascade do |t|
    t.bigint "manifestation_custom_property_id", null: false
    t.bigint "manifestation_id", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manifestation_custom_property_id", "manifestation_id"], name: "index_manifestation_custom_values_on_property_manifestation", unique: true
    t.index ["manifestation_custom_property_id"], name: "index_manifestation_custom_values_on_custom_property_id"
    t.index ["manifestation_id"], name: "index_manifestation_custom_values_on_manifestation_id"
  end

  create_table "manifestation_relationship_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manifestation_relationships", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.integer "child_id"
    t.integer "manifestation_relationship_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.index ["child_id"], name: "index_manifestation_relationships_on_child_id"
    t.index ["parent_id"], name: "index_manifestation_relationships_on_parent_id"
  end

  create_table "manifestation_reserve_stat_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "manifestation_reserve_stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["manifestation_reserve_stat_id", "most_recent"], name: "index_manifestation_reserve_stat_transitions_parent_most_recen", unique: true, where: "most_recent"
    t.index ["manifestation_reserve_stat_id"], name: "index_manifestation_reserve_stat_transitions_on_stat_id"
    t.index ["sort_key", "manifestation_reserve_stat_id"], name: "index_manifestation_reserve_stat_transitions_on_transition", unique: true
  end

  create_table "manifestation_reserve_stats", id: :serial, force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_manifestation_reserve_stats_on_user_id"
  end

  create_table "manifestations", id: :serial, force: :cascade do |t|
    t.text "original_title", null: false
    t.text "title_alternative"
    t.text "title_transcription"
    t.string "classification_number"
    t.string "manifestation_identifier"
    t.datetime "date_of_publication"
    t.datetime "date_copyrighted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "access_address"
    t.integer "language_id", default: 1, null: false
    t.integer "carrier_type_id", default: 1, null: false
    t.integer "start_page"
    t.integer "end_page"
    t.integer "height"
    t.integer "width"
    t.integer "depth"
    t.integer "price"
    t.text "fulltext"
    t.string "volume_number_string"
    t.string "issue_number_string"
    t.string "serial_number_string"
    t.integer "edition"
    t.text "note"
    t.boolean "repository_content", default: false, null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "required_role_id", default: 1, null: false
    t.integer "required_score", default: 0, null: false
    t.integer "frequency_id", default: 1, null: false
    t.boolean "subscription_master", default: false, null: false
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer "nii_type_id"
    t.text "title_alternative_transcription"
    t.text "description"
    t.text "abstract"
    t.datetime "available_at"
    t.datetime "valid_until"
    t.datetime "date_submitted"
    t.datetime "date_accepted"
    t.datetime "date_captured"
    t.string "pub_date"
    t.string "edition_string"
    t.integer "volume_number"
    t.integer "issue_number"
    t.integer "serial_number"
    t.integer "content_type_id", default: 1
    t.integer "year_of_publication"
    t.text "attachment_meta"
    t.integer "month_of_publication"
    t.boolean "fulltext_content"
    t.boolean "serial"
    t.text "statement_of_responsibility"
    t.text "publication_place"
    t.text "extent"
    t.text "dimensions"
    t.text "memo"
    t.index ["access_address"], name: "index_manifestations_on_access_address"
    t.index ["date_of_publication"], name: "index_manifestations_on_date_of_publication"
    t.index ["manifestation_identifier"], name: "index_manifestations_on_manifestation_identifier"
    t.index ["nii_type_id"], name: "index_manifestations_on_nii_type_id"
    t.index ["updated_at"], name: "index_manifestations_on_updated_at"
  end

  create_table "medium_of_performances", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_request_transitions", force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.bigint "message_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "most_recent", null: false
    t.index ["message_request_id", "most_recent"], name: "index_message_request_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["message_request_id"], name: "index_message_request_transitions_on_message_request_id"
    t.index ["sort_key", "message_request_id"], name: "index_message_request_transitions_on_sort_key_and_request_id", unique: true
  end

  create_table "message_requests", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.bigint "message_template_id"
    t.datetime "sent_at"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_template_id"], name: "index_message_requests_on_message_template_id"
    t.index ["receiver_id"], name: "index_message_requests_on_receiver_id"
    t.index ["sender_id"], name: "index_message_requests_on_sender_id"
  end

  create_table "message_templates", force: :cascade do |t|
    t.string "status", null: false
    t.text "title", null: false
    t.text "body", null: false
    t.integer "position"
    t.string "locale", default: "en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_message_templates_on_status", unique: true
  end

  create_table "message_transitions", force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.bigint "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "most_recent", null: false
    t.index ["message_id", "most_recent"], name: "index_message_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["message_id"], name: "index_message_transitions_on_message_id"
    t.index ["sort_key", "message_id"], name: "index_message_transitions_on_sort_key_and_message_id", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.datetime "read_at"
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.string "subject", null: false
    t.text "body"
    t.bigint "message_request_id"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth"
    t.index ["message_request_id"], name: "index_messages_on_message_request_id"
    t.index ["parent_id"], name: "index_messages_on_parent_id"
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "ndl_bib_id_records", force: :cascade do |t|
    t.string "body", null: false
    t.bigint "manifestation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_ndl_bib_id_records_on_body", unique: true
    t.index ["manifestation_id"], name: "index_ndl_bib_id_records_on_manifestation_id"
  end

  create_table "ndla_records", force: :cascade do |t|
    t.bigint "agent_id"
    t.string "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_ndla_records_on_agent_id"
    t.index ["body"], name: "index_ndla_records_on_body", unique: true
  end

  create_table "nii_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_nii_types_on_name", unique: true
  end

  create_table "owns", id: :serial, force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "item_id", null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["agent_id"], name: "index_owns_on_agent_id"
    t.index ["item_id"], name: "index_owns_on_item_id"
  end

  create_table "participates", id: :serial, force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "event_id", null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["agent_id"], name: "index_participates_on_agent_id"
    t.index ["event_id"], name: "index_participates_on_event_id"
  end

  create_table "picture_files", id: :serial, force: :cascade do |t|
    t.integer "picture_attachable_id"
    t.string "picture_attachable_type"
    t.text "title"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "picture_file_name"
    t.string "picture_content_type"
    t.integer "picture_file_size"
    t.datetime "picture_updated_at"
    t.text "picture_meta"
    t.string "picture_fingerprint"
    t.integer "picture_width"
    t.integer "picture_height"
    t.index ["picture_attachable_id", "picture_attachable_type"], name: "index_picture_files_on_picture_attachable_id_and_type"
  end

  create_table "places", id: :serial, force: :cascade do |t|
    t.string "term"
    t.text "city"
    t.integer "country_id"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_places_on_country_id"
    t.index ["term"], name: "index_places_on_term"
  end

  create_table "produce_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "produces", id: :serial, force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "manifestation_id", null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "produce_type_id"
    t.index ["agent_id"], name: "index_produces_on_agent_id"
    t.index ["manifestation_id"], name: "index_produces_on_manifestation_id"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "user_group_id"
    t.integer "library_id"
    t.string "locale"
    t.string "user_number"
    t.text "full_name"
    t.text "note"
    t.text "keyword_list"
    t.integer "required_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "checkout_icalendar_token"
    t.boolean "save_checkout_history", default: false, null: false
    t.datetime "expired_at"
    t.boolean "share_bookmarks"
    t.text "full_name_transcription"
    t.datetime "date_of_birth"
    t.index ["checkout_icalendar_token"], name: "index_profiles_on_checkout_icalendar_token", unique: true
    t.index ["library_id"], name: "index_profiles_on_library_id"
    t.index ["user_group_id"], name: "index_profiles_on_user_group_id"
    t.index ["user_id"], name: "index_profiles_on_user_id"
    t.index ["user_number"], name: "index_profiles_on_user_number", unique: true
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "body"
    t.boolean "shared", default: true, null: false
    t.integer "answers_count", default: 0, null: false
    t.datetime "deleted_at"
    t.string "state"
    t.boolean "solved", default: false, null: false
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "realize_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "realizes", id: :serial, force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "expression_id", null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "realize_type_id"
    t.index ["agent_id"], name: "index_realizes_on_agent_id"
    t.index ["expression_id"], name: "index_realizes_on_expression_id"
  end

  create_table "request_status_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reserve_stat_has_manifestations", id: :serial, force: :cascade do |t|
    t.integer "manifestation_reserve_stat_id", null: false
    t.integer "manifestation_id", null: false
    t.integer "reserves_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["manifestation_id"], name: "index_reserve_stat_has_manifestations_on_manifestation_id"
    t.index ["manifestation_reserve_stat_id"], name: "index_reserve_stat_has_manifestations_on_m_reserve_stat_id"
  end

  create_table "reserve_stat_has_users", id: :serial, force: :cascade do |t|
    t.integer "user_reserve_stat_id", null: false
    t.integer "user_id", null: false
    t.integer "reserves_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_reserve_stat_has_users_on_user_id"
    t.index ["user_reserve_stat_id"], name: "index_reserve_stat_has_users_on_user_reserve_stat_id"
  end

  create_table "reserve_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "reserve_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["reserve_id", "most_recent"], name: "index_reserve_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["reserve_id"], name: "index_reserve_transitions_on_reserve_id"
    t.index ["sort_key", "reserve_id"], name: "index_reserve_transitions_on_sort_key_and_reserve_id", unique: true
  end

  create_table "reserves", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "manifestation_id", null: false
    t.integer "item_id"
    t.integer "request_status_type_id", null: false
    t.datetime "checked_out_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "canceled_at"
    t.datetime "expired_at"
    t.datetime "deleted_at"
    t.boolean "expiration_notice_to_patron", default: false
    t.boolean "expiration_notice_to_library", default: false
    t.integer "pickup_location_id"
    t.datetime "retained_at"
    t.datetime "postponed_at"
    t.integer "lock_version", default: 0, null: false
    t.index ["item_id"], name: "index_reserves_on_item_id"
    t.index ["manifestation_id"], name: "index_reserves_on_manifestation_id"
    t.index ["pickup_location_id"], name: "index_reserves_on_pickup_location_id"
    t.index ["user_id"], name: "index_reserves_on_user_id"
  end

  create_table "resource_export_file_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "resource_export_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["resource_export_file_id", "most_recent"], name: "index_resource_export_file_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["resource_export_file_id"], name: "index_resource_export_file_transitions_on_file_id"
    t.index ["sort_key", "resource_export_file_id"], name: "index_resource_export_file_transitions_on_sort_key_and_file_id", unique: true
  end

  create_table "resource_export_files", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "resource_export_file_name"
    t.string "resource_export_content_type"
    t.bigint "resource_export_file_size"
    t.datetime "resource_export_updated_at"
    t.datetime "executed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_import_file_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "resource_import_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["resource_import_file_id", "most_recent"], name: "index_resource_import_file_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["resource_import_file_id"], name: "index_resource_import_file_transitions_on_file_id"
    t.index ["sort_key", "resource_import_file_id"], name: "index_resource_import_file_transitions_on_sort_key_and_file_id", unique: true
  end

  create_table "resource_import_files", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.string "content_type"
    t.integer "size"
    t.integer "user_id"
    t.text "note"
    t.datetime "executed_at"
    t.string "resource_import_file_name"
    t.string "resource_import_content_type"
    t.integer "resource_import_file_size"
    t.datetime "resource_import_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "edit_mode"
    t.string "resource_import_fingerprint"
    t.text "error_message"
    t.string "user_encoding"
    t.integer "default_shelf_id"
    t.index ["parent_id"], name: "index_resource_import_files_on_parent_id"
    t.index ["user_id"], name: "index_resource_import_files_on_user_id"
  end

  create_table "resource_import_results", id: :serial, force: :cascade do |t|
    t.integer "resource_import_file_id"
    t.integer "manifestation_id"
    t.integer "item_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "error_message"
    t.index ["item_id"], name: "index_resource_import_results_on_item_id"
    t.index ["manifestation_id"], name: "index_resource_import_results_on_manifestation_id"
    t.index ["resource_import_file_id"], name: "index_resource_import_results_on_resource_import_file_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "score", default: 0, null: false
    t.integer "position"
  end

  create_table "search_engines", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.string "url", null: false
    t.text "base_url", null: false
    t.text "http_method", null: false
    t.text "query_param", null: false
    t.text "additional_param"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series_statement_merge_lists", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series_statement_merges", id: :serial, force: :cascade do |t|
    t.integer "series_statement_id", null: false
    t.integer "series_statement_merge_list_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["series_statement_id"], name: "index_series_statement_merges_on_series_statement_id"
    t.index ["series_statement_merge_list_id"], name: "index_series_statement_merges_on_list_id"
  end

  create_table "series_statements", id: :serial, force: :cascade do |t|
    t.text "original_title"
    t.text "numbering"
    t.text "title_subseries"
    t.text "numbering_subseries"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "title_transcription"
    t.text "title_alternative"
    t.string "series_statement_identifier"
    t.integer "manifestation_id"
    t.text "note"
    t.text "title_subseries_transcription"
    t.text "creator_string"
    t.text "volume_number_string"
    t.text "volume_number_transcription_string"
    t.boolean "series_master"
    t.integer "root_manifestation_id"
    t.index ["manifestation_id"], name: "index_series_statements_on_manifestation_id"
    t.index ["root_manifestation_id"], name: "index_series_statements_on_root_manifestation_id"
    t.index ["series_statement_identifier"], name: "index_series_statements_on_series_statement_identifier"
  end

  create_table "shelves", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "library_id", null: false
    t.integer "items_count", default: 0, null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean "closed", default: false, null: false
    t.index ["library_id"], name: "index_shelves_on_library_id"
  end

  create_table "subject_heading_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.integer "use_term_id"
    t.string "term"
    t.text "term_transcription"
    t.integer "subject_type_id", null: false
    t.text "scope_note"
    t.text "note"
    t.integer "required_role_id", default: 1, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "url"
    t.integer "manifestation_id"
    t.integer "subject_heading_type_id"
    t.index ["manifestation_id"], name: "index_subjects_on_manifestation_id"
    t.index ["parent_id"], name: "index_subjects_on_parent_id"
    t.index ["required_role_id"], name: "index_subjects_on_required_role_id"
    t.index ["subject_type_id"], name: "index_subjects_on_subject_type_id"
    t.index ["term"], name: "index_subjects_on_term"
    t.index ["use_term_id"], name: "index_subjects_on_use_term_id"
  end

  create_table "subscribes", id: :serial, force: :cascade do |t|
    t.integer "subscription_id", null: false
    t.integer "work_id", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["subscription_id"], name: "index_subscribes_on_subscription_id"
    t.index ["work_id"], name: "index_subscribes_on_work_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.text "note"
    t.integer "user_id"
    t.integer "order_list_id"
    t.datetime "deleted_at"
    t.integer "subscribes_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["order_list_id"], name: "index_subscriptions_on_order_list_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "use_restrictions", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_checkout_stat_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "user_checkout_stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["sort_key", "user_checkout_stat_id"], name: "index_user_checkout_stat_transitions_on_sort_key_and_stat_id", unique: true
    t.index ["user_checkout_stat_id", "most_recent"], name: "index_user_checkout_stat_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["user_checkout_stat_id"], name: "index_user_checkout_stat_transitions_on_user_checkout_stat_id"
  end

  create_table "user_checkout_stats", id: :serial, force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_user_checkout_stats_on_user_id"
  end

  create_table "user_export_file_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "user_export_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["sort_key", "user_export_file_id"], name: "index_user_export_file_transitions_on_sort_key_and_file_id", unique: true
    t.index ["user_export_file_id", "most_recent"], name: "index_user_export_file_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["user_export_file_id"], name: "index_user_export_file_transitions_on_file_id"
    t.index ["user_export_file_id"], name: "index_user_export_file_transitions_on_user_export_file_id"
  end

  create_table "user_export_files", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "user_export_file_name"
    t.string "user_export_content_type"
    t.bigint "user_export_file_size"
    t.datetime "user_export_updated_at"
    t.datetime "executed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_user_export_files_on_user_id"
  end

  create_table "user_group_has_checkout_types", id: :serial, force: :cascade do |t|
    t.integer "user_group_id", null: false
    t.integer "checkout_type_id", null: false
    t.integer "checkout_limit", default: 0, null: false
    t.integer "checkout_period", default: 0, null: false
    t.integer "checkout_renewal_limit", default: 0, null: false
    t.integer "reservation_limit", default: 0, null: false
    t.integer "reservation_expired_period", default: 7, null: false
    t.boolean "set_due_date_before_closing_day", default: false, null: false
    t.datetime "fixed_due_date"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "current_checkout_count"
    t.index ["checkout_type_id"], name: "index_user_group_has_checkout_types_on_checkout_type_id"
    t.index ["user_group_id"], name: "index_user_group_has_checkout_types_on_user_group_id"
  end

  create_table "user_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "display_name"
    t.text "note"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer "valid_period_for_new_user", default: 0, null: false
    t.datetime "expired_at"
    t.integer "number_of_day_to_notify_overdue", default: 0, null: false
    t.integer "number_of_day_to_notify_due_date", default: 0, null: false
    t.integer "number_of_time_to_notify_overdue", default: 0, null: false
  end

  create_table "user_has_roles", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["role_id"], name: "index_user_has_roles_on_role_id"
    t.index ["user_id"], name: "index_user_has_roles_on_user_id"
  end

  create_table "user_import_file_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "user_import_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["sort_key", "user_import_file_id"], name: "index_user_import_file_transitions_on_sort_key_and_file_id", unique: true
    t.index ["user_import_file_id", "most_recent"], name: "index_user_import_file_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["user_import_file_id"], name: "index_user_import_file_transitions_on_user_import_file_id"
  end

  create_table "user_import_files", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "note"
    t.datetime "executed_at"
    t.string "user_import_file_name"
    t.string "user_import_content_type"
    t.integer "user_import_file_size"
    t.datetime "user_import_updated_at"
    t.string "user_import_fingerprint"
    t.string "edit_mode"
    t.text "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "user_encoding"
    t.integer "default_library_id"
    t.integer "default_user_group_id"
    t.index ["user_id"], name: "index_user_import_files_on_user_id"
  end

  create_table "user_import_results", id: :serial, force: :cascade do |t|
    t.integer "user_import_file_id"
    t.integer "user_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "error_message"
    t.index ["user_id"], name: "index_user_import_results_on_user_id"
    t.index ["user_import_file_id"], name: "index_user_import_results_on_user_import_file_id"
  end

  create_table "user_reserve_stat_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state"
    t.text "metadata", default: "{}"
    t.integer "sort_key"
    t.integer "user_reserve_stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent", null: false
    t.index ["sort_key", "user_reserve_stat_id"], name: "index_user_reserve_stat_transitions_on_sort_key_and_stat_id", unique: true
    t.index ["user_reserve_stat_id", "most_recent"], name: "index_user_reserve_stat_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["user_reserve_stat_id"], name: "index_user_reserve_stat_transitions_on_user_reserve_stat_id"
  end

  create_table "user_reserve_stats", id: :serial, force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "user_id"
    t.index ["user_id"], name: "index_user_reserve_stats_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "answer_feed_token"
    t.string "username"
    t.datetime "deleted_at"
    t.datetime "expired_at"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "confirmed_at"
    t.index ["answer_feed_token"], name: "index_users_on_answer_feed_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "withdraws", id: :serial, force: :cascade do |t|
    t.integer "basket_id"
    t.integer "item_id"
    t.integer "librarian_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["basket_id"], name: "index_withdraws_on_basket_id"
    t.index ["item_id"], name: "index_withdraws_on_item_id"
    t.index ["librarian_id"], name: "index_withdraws_on_librarian_id"
  end

  add_foreign_key "carrier_type_has_checkout_types", "carrier_types"
  add_foreign_key "carrier_type_has_checkout_types", "checkout_types"
  add_foreign_key "checked_items", "baskets"
  add_foreign_key "checked_items", "items"
  add_foreign_key "checked_items", "users"
  add_foreign_key "checkins", "items"
  add_foreign_key "checkout_stat_has_manifestations", "manifestations"
  add_foreign_key "checkout_stat_has_users", "user_checkout_stats"
  add_foreign_key "checkout_stat_has_users", "users"
  add_foreign_key "checkouts", "checkins"
  add_foreign_key "checkouts", "items"
  add_foreign_key "checkouts", "libraries"
  add_foreign_key "checkouts", "shelves"
  add_foreign_key "checkouts", "users"
  add_foreign_key "demands", "items"
  add_foreign_key "demands", "messages"
  add_foreign_key "demands", "users"
  add_foreign_key "events", "event_categories"
  add_foreign_key "inventory_files", "shelves"
  add_foreign_key "item_custom_values", "item_custom_properties"
  add_foreign_key "item_custom_values", "items"
  add_foreign_key "item_has_use_restrictions", "items"
  add_foreign_key "item_has_use_restrictions", "use_restrictions"
  add_foreign_key "items", "manifestations"
  add_foreign_key "jpno_records", "manifestations"
  add_foreign_key "lending_policies", "items"
  add_foreign_key "lending_policies", "user_groups"
  add_foreign_key "libraries", "library_groups"
  add_foreign_key "library_groups", "users"
  add_foreign_key "manifestation_checkout_stats", "users"
  add_foreign_key "manifestation_custom_values", "manifestation_custom_properties"
  add_foreign_key "manifestation_custom_values", "manifestations"
  add_foreign_key "manifestation_reserve_stats", "users"
  add_foreign_key "messages", "messages", column: "parent_id"
  add_foreign_key "ndl_bib_id_records", "manifestations"
  add_foreign_key "ndla_records", "agents"
  add_foreign_key "profiles", "users"
  add_foreign_key "reserve_stat_has_manifestations", "manifestations"
  add_foreign_key "reserve_stat_has_users", "user_reserve_stats"
  add_foreign_key "reserve_stat_has_users", "users"
  add_foreign_key "reserves", "manifestations"
  add_foreign_key "reserves", "users"
  add_foreign_key "user_checkout_stats", "users"
  add_foreign_key "user_group_has_checkout_types", "checkout_types"
  add_foreign_key "user_group_has_checkout_types", "user_groups"
  add_foreign_key "user_has_roles", "roles"
  add_foreign_key "user_has_roles", "users"
  add_foreign_key "user_reserve_stats", "users"
end

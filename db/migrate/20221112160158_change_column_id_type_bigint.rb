class ChangeColumnIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)

      change_column table, :id, :bigint
    end

    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)

      columns = ActiveRecord::Base.connection.columns(table).map(&:name)
      change_column table, :user_id, :bigint if columns.include?('user_id')
      change_column table, :librarian_id, :bigint if columns.include?('librarian_id')
    end

    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)
      next unless ActiveRecord::Base.connection.columns(table).map(&:name).include?('agent_id')

      change_column table, :agent_id, :bigint
    end

    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)
      next unless ActiveRecord::Base.connection.columns(table).map(&:name).include?('manifestation_id')

      change_column table, :manifestation_id, :bigint
    end

    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)
      next unless ActiveRecord::Base.connection.columns(table).map(&:name).include?('library_id')

      change_column table, :library_id, :bigint
    end

    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)
      next unless ActiveRecord::Base.connection.columns(table).map(&:name).include?('item_id')

      change_column table, :item_id, :bigint
    end

    [
      :accepts,
      :checked_items,
      :checkins,
      :checkouts,
      :withdraws
    ].each do |table|
      change_column table, :basket_id, :bigint
    end

    change_column :checkouts, :shelf_id, :bigint
    change_column :items, :shelf_id, :bigint
    change_column :resource_import_files, :default_shelf_id, :bigint

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

    [
      :colors,
      :libraries,
      :library_group_translations,
      :news_feeds
    ].each do |table|
      change_column table, :library_group_id, :bigint
    end

    [
      :accepts,
      :checked_items,
      :checkins,
      :checkouts,
      :withdraws
    ].each do |table|
      change_column table, :basket_id, :bigint
    end

    [
      :agents,
      :libraries,
      :library_groups,
      :places
    ].each do |table|
      change_column table, :country_id, :bigint
    end

    [
      :agent_import_files,
      :agent_relationships,
      :classifications,
      :event_import_files,
      :manifestation_relationships,
      :resource_import_files,
      :subjects
    ].each do |table|
      change_column table, :parent_id, :bigint
    end

    [
      :agent_relationships,
      :manifestation_relationships
    ].each do |table|
      change_column table, :child_id, :bigint
    end

    [
      :creates,
      :subscribes
    ].each do |table|
      change_column table, :work_id, :bigint
    end

    [
      :agents,
      :manifestations
    ].each do |table|
      change_column table, :language_id, :bigint
    end

    [
      :agents,
      :identities
    ].each do |table|
      change_column table, :profile_id, :bigint
    end

    [
      :profiles,
      :user_group_has_checkout_types
    ].each do |table|
      change_column table, :user_group_id, :bigint
    end

    [
      :carrier_type_has_checkout_types,
      :manifestations
    ].each do |table|
      change_column table, :carrier_type_id, :bigint
    end

    [
      :carrier_type_has_checkout_types,
      :items,
      :user_group_has_checkout_types
    ].each do |table|
      change_column table, :checkout_type_id, :bigint
    end

    change_column :agent_import_file_transitions, :agent_import_file_id, :bigint
    change_column :agent_import_results, :agent_import_file_id, :bigint
    change_column :agent_merges, :agent_merge_list_id, :bigint
    change_column :agent_relationships, :agent_relationship_type_id, :bigint
    change_column :agents, :agent_type_id, :bigint
    change_column :bookmark_stat_has_manifestations, :bookmark_stat_id, :bigint
    change_column :bookmark_stat_transitions, :bookmark_stat_id, :bigint
    change_column :checkout_stat_has_manifestations, :manifestation_checkout_stat_id, :bigint
    change_column :checkout_stat_has_users, :user_checkout_stat_id, :bigint
    change_column :checkouts, :checkin_id, :bigint
    change_column :classifications, :classification_type_id, :bigint
    change_column :creates, :create_type_id, :bigint
    change_column :demands, :message_id, :bigint
    change_column :event_export_file_transitions, :event_export_file_id, :bigint
    change_column :event_import_file_transitions, :event_import_file_id, :bigint
    change_column :event_import_files, :default_library_id, :bigint
    change_column :event_import_files, :default_event_category_id, :bigint
    change_column :event_import_results, :event_import_file_id, :bigint
    change_column :event_import_results, :event_id, :bigint
    change_column :events, :event_category_id, :bigint
    change_column :events, :place_id, :bigint
    change_column :identifiers, :identifier_type_id, :bigint
    change_column :import_request_transitions, :import_request_id, :bigint
    change_column :inventories, :inventory_file_id, :bigint
    change_column :item_has_use_restrictions, :use_restriction_id, :bigint
    change_column :items, :bookstore_id, :bigint
    change_column :items, :budget_type_id, :bigint
    change_column :items, :circulation_status_id, :bigint
    change_column :manifestation_checkout_stat_transitions, :manifestation_checkout_stat_id, :bigint
    change_column :manifestation_relationships, :manifestation_relationship_type_id, :bigint
    change_column :manifestation_reserve_stat_transitions, :manifestation_reserve_stat_id, :bigint
    change_column :manifestations, :frequency_id, :bigint
    change_column :manifestations, :nii_type_id, :bigint
    change_column :manifestations, :content_type_id, :bigint
    change_column :participates, :event_id, :bigint
    change_column :picture_files, :picture_attachable_id, :bigint
    change_column :produces, :produce_type_id, :bigint
    change_column :realizes, :expression_id, :bigint
    change_column :realizes, :realize_type_id, :bigint
    change_column :reserve_stat_has_manifestations, :manifestation_reserve_stat_id, :bigint
    change_column :reserve_stat_has_users, :user_reserve_stat_id, :bigint
    change_column :reserve_transitions, :reserve_id, :bigint
    change_column :reserves, :request_status_type_id, :bigint
    change_column :reserves, :pickup_location_id, :bigint
    change_column :resource_export_file_transitions, :resource_export_file_id, :bigint
    change_column :resource_import_file_transitions, :resource_import_file_id, :bigint
    change_column :resource_import_results, :resource_import_file_id, :bigint
    change_column :series_statement_merges, :series_statement_id, :bigint
    change_column :series_statement_merges, :series_statement_merge_list_id, :bigint
    change_column :series_statements, :root_manifestation_id, :bigint
    change_column :subjects, :use_term_id, :bigint
    change_column :subjects, :subject_heading_type_id, :bigint
    change_column :subjects, :subject_type_id, :bigint
    change_column :subscribes, :subscription_id, :bigint
    change_column :subscriptions, :order_list_id, :bigint
    change_column :taggings, :tag_id, :bigint
    change_column :taggings, :taggable_id, :bigint
    change_column :taggings, :tagger_id, :bigint
    change_column :user_checkout_stat_transitions, :user_checkout_stat_id, :bigint
    change_column :user_export_file_transitions, :user_export_file_id, :bigint
    change_column :user_import_file_transitions, :user_import_file_id, :bigint
    change_column :user_import_files, :default_library_id, :bigint
    change_column :user_import_files, :default_user_group_id, :bigint
    change_column :user_import_results, :user_import_file_id, :bigint
    change_column :user_reserve_stat_transitions, :user_reserve_stat_id, :bigint
  end
end

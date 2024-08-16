class AddIndexToLibrariesOnName < ActiveRecord::Migration[6.1]
  def change
    [
      :budget_types,
      :create_types,
      :events,
      :identifier_types,
      :identities,
      :produce_types,
      :realize_types,
      :tags,
      :user_groups
    ].each do |table|
      change_column_null table, :name, false
    end

    [
      :libraries,
      :checkout_types,
      :countries,
      :item_custom_properties,
      :languages,
      :manifestation_custom_properties,
      :nii_types,
    ].each do |table|
      remove_index table, :name, if_exists: true
    end

    [
      :libraries,
      :roles,
      :agent_relationship_types,
      :agent_types,
      :budget_types,
      :carrier_types,
      :checkout_types,
      :circulation_statuses,
      :classification_types,
      :content_types,
      :countries,
      :create_types,
      :form_of_works,
      :frequencies,
      :identifier_types,
      :shelves,
      :item_custom_properties,
      :languages,
      :library_groups,
      :licenses,
      :manifestation_custom_properties,
      :manifestation_relationship_types,
      :medium_of_performances,
      :nii_types,
      :produce_types,
      :realize_types,
      :request_status_types,
      :request_types,
      :subject_heading_types,
      :subject_types,
      :use_restrictions,
      :user_groups
    ].each do |table|
      add_index table, 'lower(name)', unique: true
    end
  end
end

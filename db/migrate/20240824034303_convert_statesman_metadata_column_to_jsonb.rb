class ConvertStatesmanMetadataColumnToJsonb < ActiveRecord::Migration[7.1]
  def up
    %w(
      agent_import_file event_import_file resource_import_file user_import_file
      resource_export_file user_export_file
      manifestation_checkout_stat manifestation_reserve_stat
      user_checkout_stat user_reserve_stat bookmark_stat
      import_request message order_list reserve
    ).each do |name|
      change_column_default :"#{name}_transitions", :metadata, from: '{}', to: nil
      change_column :"#{name}_transitions", :metadata, :jsonb, using: 'metadata::text::jsonb'
      change_column_default :"#{name}_transitions", :metadata, from: nil, to: {}
      change_column_null :"#{name}_transitions", :metadata, false
    end
  end

  def down
    %w(
      agent_import_file event_import_file resource_import_file user_import_file
      resource_export_file user_export_file
      manifestation_checkout_stat manifestation_reserve_stat
      user_checkout_stat user_reserve_stat bookmark_stat
      import_request message order_list reserve
    ).each do |name|
      change_column :"#{name}_transitions", :metadata, :text
      change_column_default :"#{name}_transitions", :metadata, from: nil, to: '{]'
      change_column_null :"#{name}_transitions", :metadata, true
    end
  end
end

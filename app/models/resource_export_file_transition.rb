class ResourceExportFileTransition < ApplicationRecord
  belongs_to :resource_export_file, inverse_of: :resource_export_file_transitions
end

# == Schema Information
#
# Table name: resource_export_file_transitions
#
#  id                      :bigint           not null, primary key
#  metadata                :jsonb            not null
#  most_recent             :boolean          not null
#  sort_key                :integer
#  to_state                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  resource_export_file_id :bigint
#
# Indexes
#
#  index_resource_export_file_transitions_on_file_id               (resource_export_file_id)
#  index_resource_export_file_transitions_on_sort_key_and_file_id  (sort_key,resource_export_file_id) UNIQUE
#  index_resource_export_file_transitions_parent_most_recent       (resource_export_file_id,most_recent) UNIQUE WHERE most_recent
#

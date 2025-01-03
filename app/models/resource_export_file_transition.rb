class ResourceExportFileTransition < ApplicationRecord
  belongs_to :resource_export_file, inverse_of: :resource_export_file_transitions
end

# == Schema Information
#
# Table name: resource_export_file_transitions
#
#  id                      :bigint           not null, primary key
#  to_state                :string
#  metadata                :jsonb            not null
#  sort_key                :integer
#  resource_export_file_id :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  most_recent             :boolean          not null
#

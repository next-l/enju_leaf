class ResourceExportFileTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :resource_export_file, inverse_of: :resource_export_file_transitions
end

# == Schema Information
#
# Table name: resource_export_file_transitions
#
#  id                      :integer          not null, primary key
#  to_state                :string
#  metadata                :text             default({})
#  sort_key                :integer
#  resource_export_file_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  most_recent             :boolean          not null
#

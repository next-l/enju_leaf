class EventExportFileTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition


  belongs_to :event_export_file, inverse_of: :event_export_file_transitions
end

# == Schema Information
#
# Table name: event_export_file_transitions
#
#  id                   :integer          not null, primary key
#  to_state             :string
#  metadata             :text             default({})
#  sort_key             :integer
#  event_export_file_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#  most_recent          :boolean          not null
#

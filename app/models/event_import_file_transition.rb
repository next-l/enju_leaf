class EventImportFileTransition < ApplicationRecord
  belongs_to :event_import_file, inverse_of: :event_import_file_transitions
end

# == Schema Information
#
# Table name: event_import_file_transitions
#
#  id                   :bigint           not null, primary key
#  metadata             :jsonb            not null
#  most_recent          :boolean          not null
#  sort_key             :integer
#  to_state             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  event_import_file_id :bigint
#
# Indexes
#
#  index_event_import_file_transitions_on_event_import_file_id  (event_import_file_id)
#  index_event_import_file_transitions_on_sort_key_and_file_id  (sort_key,event_import_file_id) UNIQUE
#  index_event_import_file_transitions_parent_most_recent       (event_import_file_id,most_recent) UNIQUE WHERE most_recent
#

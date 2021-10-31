class EventImportResult < ApplicationRecord
  scope :file_id, proc{|file_id| where(event_import_file_id: file_id)}
  scope :failed, -> { where(event_id: nil) }

  belongs_to :event_import_file
  belongs_to :event, optional: true

  validates :event_import_file_id, presence: true

  def self.header
    %w(
      id name display_name library event_category start_at end_at all_day note dummy
    )
  end
end

# == Schema Information
#
# Table name: event_import_results
#
#  id                   :integer          not null, primary key
#  event_import_file_id :integer
#  event_id             :integer
#  body                 :text
#  created_at           :datetime
#  updated_at           :datetime
#

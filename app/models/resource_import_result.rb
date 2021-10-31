class ResourceImportResult < ApplicationRecord
  default_scope { order('resource_import_results.id') }
  scope :file_id, proc{|file_id| where(resource_import_file_id: file_id)}
  scope :failed, -> { where(manifestation_id: nil) }
  scope :skipped, -> { where('error_message IS NOT NULL') }

  belongs_to :resource_import_file
  belongs_to :manifestation, optional: true
  belongs_to :item, optional: true

  validates_presence_of :resource_import_file_id
end

# == Schema Information
#
# Table name: resource_import_results
#
#  id                      :integer          not null, primary key
#  resource_import_file_id :integer
#  manifestation_id        :integer
#  item_id                 :integer
#  body                    :text
#  created_at              :datetime
#  updated_at              :datetime
#  error_message           :text
#

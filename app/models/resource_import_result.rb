class ResourceImportResult < ApplicationRecord
  default_scope { order("resource_import_results.id") }
  scope :file_id, proc { |file_id| where(resource_import_file_id: file_id) }
  scope :failed, -> { where(manifestation_id: nil) }
  scope :skipped, -> { where.not(error_message: nil) }

  belongs_to :resource_import_file
  belongs_to :manifestation, optional: true
  belongs_to :item, optional: true
end

# == Schema Information
#
# Table name: resource_import_results
#
#  id                      :bigint           not null, primary key
#  body                    :text
#  error_message           :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  item_id                 :bigint
#  manifestation_id        :bigint
#  resource_import_file_id :bigint
#
# Indexes
#
#  index_resource_import_results_on_item_id                  (item_id)
#  index_resource_import_results_on_manifestation_id         (manifestation_id)
#  index_resource_import_results_on_resource_import_file_id  (resource_import_file_id)
#

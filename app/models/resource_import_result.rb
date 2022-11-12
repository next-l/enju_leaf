class ResourceImportResult < ApplicationRecord
  default_scope { order('resource_import_results.id') }
  scope :file_id, proc{|file_id| where(resource_import_file_id: file_id)}
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
#  resource_import_file_id :integer
#  manifestation_id        :bigint
#  item_id                 :bigint
#  body                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  error_message           :text
#

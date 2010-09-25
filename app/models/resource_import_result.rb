class ResourceImportResult < ActiveRecord::Base
  belongs_to :resource_import_file
  belongs_to :manifestation, :class_name => 'Resource'
  belongs_to :item

  validates_presence_of :resource_import_file_id
end

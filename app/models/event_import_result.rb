class EventImportResult < ActiveRecord::Base
  belongs_to :event_import_file
  belongs_to :event

  validates_presence_of :event_import_file_id
end

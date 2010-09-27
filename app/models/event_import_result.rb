class EventImportResult < ActiveRecord::Base
  default_scope :order => 'event_import_results.id'
  scope :file_id, proc{|file_id| {:conditions => {:event_import_file_id => file_id}}}
  scope :failed, {:conditions => {:event_id => nil}}

  belongs_to :event_import_file
  belongs_to :event

  validates_presence_of :event_import_file_id
end

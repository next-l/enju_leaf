class EventImportResult < ActiveRecord::Base
  default_scope :order => 'event_import_results.id'
  scope :file_id, proc{|file_id| {:conditions => {:event_import_file_id => file_id}}}
  scope :failed, where(:event_id => nil)

  belongs_to :event_import_file
  belongs_to :event

  validates_presence_of :event_import_file_id
end

# == Schema Information
#
# Table name: event_import_results
#
#  id                   :integer         not null, primary key
#  event_import_file_id :integer
#  event_id             :integer
#  body                 :text
#  created_at           :datetime
#  updated_at           :datetime
#


class PatronImportResult < ActiveRecord::Base
  default_scope :order => 'patron_import_results.id'
  scope :file_id, proc{|file_id| where(:patron_import_file_id => file_id)}
  scope :failed, where(:patron_id => nil)

  belongs_to :patron_import_file
  belongs_to :patron
  belongs_to :user

  validates_presence_of :patron_import_file_id
end

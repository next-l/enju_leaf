class PatronImportResult < ActiveRecord::Base
  belongs_to :patron_import_file
  belongs_to :patron
  belongs_to :user

  validates_presence_of :patron_import_file_id
end

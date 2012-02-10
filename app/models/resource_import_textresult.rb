class ResourceImportTextresult < ActiveRecord::Base
  default_scope :order => 'resource_import_textresults.id DESC'
  scope :file_id, proc{|file_id| where(:resource_import_textfile_id => file_id)}
  scope :failed, where(:manifestation_id => nil)

  belongs_to :resource_import_textfile
  #belongs_to :manifestation
  #belongs_to :item

  validates_presence_of :resource_import_textfile_id
end

# == Schema Information
#
# Table name: resource_import_results
#
#  id                      :integer         not null, primary key
#  resource_import_file_id :integer
#  manifestation_id        :integer
#  item_id                 :integer
#  body                    :text
#  created_at              :datetime
#  updated_at              :datetime
#


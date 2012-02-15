class ResourceImportTextresult < ActiveRecord::Base
  default_scope :order => 'resource_import_textresults.id DESC'
  scope :file_id, proc{|file_id| where(:resource_import_textfile_id => file_id)}
  scope :failed, where(:manifestation_id => nil)

  belongs_to :resource_import_textfile
  #belongs_to :manifestation
  #belongs_to :item

  validates_presence_of :resource_import_textfile_id

  def self.get_resource_import_textresults_tsv(resource_import_textresults)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:item_identifier, 'activerecord.models.item'],
      [:error_msg, 'activerecord.attributes.resource_import_textresult.error_msg']
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    resource_import_textresults.each do |resource_import_textresult|
      row = []
      columns.each do |column|
        case column[0]
        when :title
          title = ""
          title = resource_import_textresult.manifestation.original_title if resource_import_textresult.manifestation
          row << title
        when :item_identifier
          item_identifier = ""
          item_identifier = resource_import_textresult.item.item_identifier if resource_import_textresult.item
          row << item_identifier
        when :error_msg
          error_msg = ""
          error_msg = resource_import_textresult.error_msg if resource_import_textresult
          row << error_msg
        end
      end
      data << '"' + row.join("\"\t\"") + "\"\n"
    end
    return data
  end
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


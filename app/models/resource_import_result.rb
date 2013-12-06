class ResourceImportResult < ActiveRecord::Base
  attr_accessible :resource_import_file, :body, :error_msg
  default_scope :order => 'resource_import_results.id DESC'
  scope :file_id, proc{|file_id| where(:resource_import_file_id => file_id)}
  scope :failed, where(:manifestation_id => nil)

  belongs_to :resource_import_file
  belongs_to :manifestation
  belongs_to :item

  validates_presence_of :resource_import_file_id

  def self.get_resource_import_results_tsv(resource_import_results)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:item_identifier, 'activerecord.models.item'],
      [:error_msg, 'activerecord.attributes.resource_import_result.error_msg']
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    resource_import_results.each do |resource_import_result|
      row = []
      columns.each do |column|
        case column[0]
        when :title
          title = ""
          title = resource_import_result.manifestation.original_title if resource_import_result.manifestation
          row << title
        when :item_identifier
          item_identifier = ""
          item_identifier = resource_import_result.item.item_identifier if resource_import_result.item
          row << item_identifier
        when :error_msg
          error_msg = ""
          error_msg = resource_import_result.error_msg if resource_import_result
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


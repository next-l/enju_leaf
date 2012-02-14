class EventImportResult < ActiveRecord::Base
  default_scope :order => 'event_import_results.id DESC'
  scope :file_id, proc{|file_id| {:conditions => {:event_import_file_id => file_id}}}
  scope :failed, where(:event_id => nil)

  belongs_to :event_import_file
  belongs_to :event

  validates_presence_of :event_import_file_id

  def self.get_event_import_results_tsv(event_import_results)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:event, 'activerecord.models.event'],
      [:error_msg, 'activerecord.attributes.event_import_result.error_msg']
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    event_import_results.each do |event_import_result|
      row = []
      columns.each do |column|
        case column[0]
        when :event
          event = ""
          event = event_import_result.event.display_name.localize if event_import_result.event
          row << event
        when :error_msg
          error_msg = ""
          error_msg = event_import_result.error_msg if event_import_result
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
# Table name: event_import_results
#
#  id                   :integer         not null, primary key
#  event_import_file_id :integer
#  event_id             :integer
#  body                 :text
#  created_at           :datetime
#  updated_at           :datetime
#


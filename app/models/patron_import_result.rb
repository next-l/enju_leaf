class PatronImportResult < ActiveRecord::Base
  default_scope :order => 'patron_import_results.id DESC'
  scope :file_id, proc{|file_id| where(:patron_import_file_id => file_id)}
  scope :failed, where(:patron_id => nil)

  belongs_to :patron_import_file
  belongs_to :patron
  belongs_to :user

  validates_presence_of :patron_import_file_id

  def self.get_patron_import_results_tsv(patron_import_results)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:patron, 'activerecord.models.patron'],
      [:user, 'activerecord.models.user'],
      [:error_msg, 'activerecord.attributes.patron_import_result.error_msg']
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    patron_import_results.each do |patron_import_result|
      row = []
      columns.each do |column|
        case column[0]
        when :patron
          patron = ""
          patron = patron_import_result.patron.full_name if patron_import_result.patron
          row << patron
        when :user
          user = ""
          user = patron_import_result.user.username if patron_import_result.user 
          row << user
        when :error_msg
          error_msg = ""
          error_msg = patron_import_result.error_msg
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
# Table name: patron_import_results
#
#  id                    :integer         not null, primary key
#  patron_import_file_id :integer
#  patron_id             :integer
#  user_id               :integer
#  body                  :text
#  created_at            :datetime
#  updated_at            :datetime
#


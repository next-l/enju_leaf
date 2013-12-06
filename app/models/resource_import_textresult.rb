class ResourceImportTextresult < ActiveRecord::Base
  attr_accessible :resource_import_textfile_id, :body, :error_msg, :extraparams, :failed

  default_scope :order => 'resource_import_textresults.id DESC'
  scope :file_id, proc{|file_id| where(:resource_import_textfile_id => file_id)}
  scope :failed, where(:manifestation_id => nil)

  belongs_to :resource_import_textfile
  belongs_to :manifestation
  belongs_to :item
  #has_many :items

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

  def self.get_resource_import_textresults_excelx(resource_import_textresults)
    # initialize
    out_dir = "#{Rails.root}/private/system/manifestations_list_excelx"
    excel_filepath = "#{out_dir}/list#{Time.now.strftime('%s')}#{rand(10)}.xlsx"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)

    extraprams_list = resource_import_textresults.sort.map{ |r| r.extraparams }.uniq


    logger.info "get_manifestation_list_excelx filepath=#{excel_filepath}"
    Axlsx::Package.new do |p|
      wb = p.workbook
      wb.styles do |s|
        default_style = s.add_style :font_name => Setting.manifestation_list_print_excelx.fontname

        extraprams_list.each do |extraparams|
          wb.add_worksheet(:name => eval(extraparams)['sheet']) do |sheet|
            if eval(extraparams)['wrong_sheet']
              oo = Excelx.new(eval(extraparams)['filename'])
              oo.default_sheet = eval(extraparams)['sheet']
              begin
                oo.first_row.upto(oo.last_row) do |row|
                  datas = []
                  oo.first_column.upto(oo.last_column) do |column|
                    datas << oo.cell(row, column).to_s.strip
                  end
                  sheet.add_row datas, :types => :string, :style => Array.new(columns.size).fill(default_style)
                end 
              rescue
                  sheet.add_row [], :types => :string, :style => Array.new(columns.size).fill(default_style)
                next
              end
            else
              results = resource_import_textresults.where(:extraparams => extraparams)
              results.sort.each do |result|
                unless result.body.nil?
                  row = result.body.split(/\t/)
                  sheet.add_row row, :style => Array.new(columns.size).fill(default_style)
                  begin
                    item = Item.find(result.item_id) rescue nil
                    if item
                      if item.manifestation.article?
                        if item.reserve
                          item.reserve.revert_request rescue nil
                        end
                        item.destroy
                        result.item_id = nil
                      end
                    end
                    manifestation = Manifestation.find(result.manifestation_id) rescue nil
                    if manifestation
                      if manifestation.items.size == 0
                        manifestation.destroy
                        result.manifestation_id = nil
                      end
                    end
                    result.save!
                  rescue => e
                    logger.info "failed to destroy item: #{result.item_id}"
                    logger.info e.message
                  end
                end
              end
            end
          end
        end
        p.serialize(excel_filepath)
      end
    end
    return excel_filepath
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


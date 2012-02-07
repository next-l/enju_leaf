class LibcheckNotfoundItem < ActiveRecord::Base

  # CONSTANT
  STS_NORMAL          = 0b00000000
  STS_CHECKOUT        = 0b00000001
  STS_BINDERD         = 0b00000010 # bindered?
  STS_INVALID_2       = 0b00000100 # reserved
  STS_INVALID_3       = 0b00001000 # reserved
  STS_INVALID_4       = 0b00010000 # reserved

  def self.export(dir)
    raise "invalid parameter: no path" if dir.nil? || dir.length < 1
    tsvfile = dir + "notfound_list.tsv"
    pdffile = dir + "notfound_list.pdf"
    logger.info "output not-found resource list : " + tsvfile
    # create output path
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

    min_cnt = configatron.libcheck_notfound_with_title_cout rescue 100
    min_cnt = 100 if min_cnt.nil?
    logger.info "write not found item title if not found items count less than #{min_cnt}"

    items = LibcheckNotfoundItem.find_by_sql(
              "select item_id, item_identifier, status" +
              " from libcheck_notfound_items order by id")
    out_title = true
    if items.nil? || items.size < 1
      logger.info "notfound item data is empty"
      items = [] # avoid nil violation
    else
      logger.info "there are #{items.size} not found items"
      out_title = true if items.size < min_cnt
    end

    columns = [
      ['item_identifier','activerecord.attributes.item.item_identifier'],
      [:status_checkout, 'activerecord.attributes.libcheck_notfound_item.status_checkout'],
    ]

    File.open(tsvfile, "w") do |output|

      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      row << I18n.t('activerecord.attributes.manifestation.original_title') if out_title
      output.print '"'+row.join("\"\t\"")+"\"\n"

      if items.size > 0 # find data
        items.each do |item|

          row = []
          columns.each do |column|
            case column[0]
            when :status_checkout
              row << conv_flg(item.status, STS_CHECKOUT)
            else
              row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
            end # end of case column[0]
          end #end of columns.each

          if out_title
            ti = Item.find(item.item_id) rescue nil
            #row << (ti.nil? ? "":ti.manifestation.original_title)
            if ti.nil? || ti.manifestation.nil? then
              row << ""
            else
              row << ti.manifestation.original_title
            end
          end

          output.print '"'+row.join("\"\t\"")+"\"\n"

        end # end_of items.each
      end # end_of items is empty?

    end # end_of File.open
  
    # make pdf
    if items.nil? || items.size < 1
      logger.warn "item date is empty"
    else
      # pdf
      report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'libcheck_notfound.tlf')
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      report.start_new_page do |page|
        page.item(:date).value(Time.now)
        items.each do |item|
          page.list(:list).add_row do |row|
            row.item(:item_identifier).value(item.item_identifier)
            row.item(:title).value(Item.find(item.item_id).manifestation.original_title) rescue nil
            row.item(:on_loan).value(conv_flg(item.status, STS_CHECKOUT))
          end
        end
      end
      report.generate_file(pdffile)
    end

  rescue => exc
    logger.error exc
    raise exc
  end
  # end_of_export

  private
  def self.conv_flg(value, flg)
    return "" if value.nil? || flg.nil?
    return ((value & flg) != 0b0) ? "1":""
  end

  private
  def self.get_object_method(obj,array)
    _obj = obj.send(array.shift)
    return get_object_method(_obj, array) if array.present?
    return _obj
  end

end

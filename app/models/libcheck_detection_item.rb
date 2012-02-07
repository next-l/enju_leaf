class LibcheckDetectionItem < ActiveRecord::Base
  def self.export_detection_list(out_dir)
    raise "invalid parameter: no path" if out_dir.nil? || out_dir.length < 1
    tsv_file = out_dir + "detection_list.tsv"
    pdf_file = out_dir + "detection_list.pdf"
    logger.info "output detection_list tsv: #{tsv_file} pdf: #{pdf_file}"
    # create output path
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # get detection item
    circulation_status_ids = CirculationStatus.not_found.inject([]){|ids, circulation_status| ids << circulation_status.id; ids}
    @items = Item.joins(:libcheck_tmp_items).where(["circulation_status_id IN (?)", circulation_status_ids])
    # make tsv
    make_detection_list_tsv(tsv_file, @items)
    # make pdf
    make_detection_list_pdf(pdf_file, @items)
  end

private
  def self.make_detection_list_tsv(tsvfile, items)
    columns = [
      [:item_identifier, 'activerecord.attributes.item.item_identifier'],
      [:original_title, 'activerecord.attributes.manifestation.original_title'],
      [:shelf, 'activerecord.models.shelf'],
      [:state, 'activerecord.models.circulation_status'],
    ]

    File.open(tsvfile, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      output.print '"'+row.join("\"\t\"")+"\"\n"
      if items.nil? || items.size < 1
        logger.warn "item data is empty"
      else
        items.each do |item|
          row = []
          columns.each do |column|
            case column[0]
            when :item_identifier
              row << item.item_identifier
            when :original_title
              if item.manifestation
                row << item.manifestation.original_title
              else
                row << ""
              end
            when :shelf
              begin
                row << LibcheckTmpItem.where(["item_id = ?", item.id]).first.libcheck_shelf.shelf_name
              rescue
                row << ""
              end
            when :state
              row << item.circulation_status.display_name.localize
            end
          end
          output.print '"'+row.join("\"\t\"")+"\"\n"
        end
      end
    end
  end	
  def self.make_detection_list_pdf(pdf_file, items)
    # pdf
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'libcheck_detection.tlf')
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
          row.item(:title).value(item.manifestation.original_title) if item.manifestation
          row.item(:shelf).value(LibcheckTmpItem.where(["item_id = ?", item.id]).first.libcheck_shelf.shelf_name) rescue nil
          row.item(:circulation_status).value(item.circulation_status.display_name.localize)
        end
      end
    end
    report.generate_file(pdf_file)
  end
end



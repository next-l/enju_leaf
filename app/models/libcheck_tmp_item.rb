class LibcheckTmpItem < ActiveRecord::Base

  # CONSTANT
  STS_NO_ERROR        = 0b00000000
  STS_NOT_FOUND       = 0b00000001
  STS_INVALID_CALL_NO = 0b00000010
  STS_UNKNOWN_SHELF   = 0b00000100
  STS_DELETED         = 0b00001000
  STS_CHECKOUT_T_DIFF = 0b00010000 # different checkout_type 
  STS_NDC_WARNING     = 0b00100000 # minority NDC parse result
  STS_INVALID_SERIAL  = 0b01000000 # serial but no series_id
  STS_RESERVED8       = 0b10000000 # reserve

  CONFUSION_FLG = 1 # confused

  # this is test main
  # truncate libcheck_tmp_items table and then regist data
  # from named in_file_name
  def self.import_test_main(in_file_name)
    LibcheckTmpItem.destroy_all
    import(in_file_name)
  end
  # end_of_import_main

  # import process
  # in_file_name should be full path to the input file.
  def self.import(in_file_name)
    logger.info "staring import: input file is #{in_file_name}"

    unless File.exist?(in_file_name)
      logger.error "#{in_file_name} is not found"
    else # found!
      serial_types = configatron.libcheck_serial
      serial_types = [] if serial_types.nil?

      File.open(in_file_name) do |f|
        cur_shelf = nil
        seq_in_the_shelf = 0
        f.each_line do |line|
          #book_id = line.strip
          book_id = NKF.nkf('-Sw', line).strip
          next if book_id.empty? # ignore empty line

          book_id = book_id.gsub(/"/, '')
          #logger.debug "#{f.lineno}: #{line.strip}"

          # check shelf_id from libcheck_shelves
          shelf = LibcheckShelf.find(:first, :conditions => ["shelf_name = ?", book_id])
          unless shelf.nil? then
            # book_id is shelf_id
            if cur_shelf.nil? || cur_shelf.id != shelf.id then
              # shelf break

              # shelf end mark is not found
              logger.warn "NO_END_MARK #{cur_shelf.shelf_name}" unless cur_shelf.nil?

              cur_shelf = shelf
              seq_in_the_shelf = 1
              logger.info "starting a shelf => #{shelf.shelf_name}"
            elsif cur_shelf.id == shelf.id then
              # end of the shelf
              #logger.info "end of the shelf => #{shelf.shelf_name}"
              #cur_shelf = nil
            end

            next # don't check item with current book_id(==shelf_id)
          end

          # get item by item_identifier
          item = Item.find(:first, :conditions => ["item_identifier = ?", book_id])

          tmp_item = LibcheckTmpItem.new
          tmp_item.item_identifier = book_id
          tmp_item.confusion_flg = 0
          tmp_item.status_flg = STS_NO_ERROR
          tmp_item.no = seq_in_the_shelf
          unless cur_shelf.nil? then
            tmp_item.shelf_id = cur_shelf.id
          else
            logger.warn "Item[#{book_id}] in unknown shelf"
            tmp_item.status_flg |= STS_UNKNOWN_SHELF
          end

          if item.nil? then
            # NOT FOUND           
            tmp_item.status_flg |= STS_NOT_FOUND
            logger.info "Item #{line.strip} is not found"
          else
            tmp_item.item_id = item.id

            #title: 2011.05.17
            tmp_item.original_title = item.manifestation.original_title
            #2011.05.20: date_of_publication and edition_display_value
            tm = item.manifestation
            tmp_item.date_of_publication = tm.date_of_publication unless tm.nil?
            tmp_item.edition_display_value = tm.edition_display_value unless tm.nil?

            #check invalid serial
            t_ctype = item.checkout_type
            if !t_ctype.nil? && serial_types.include?(t_ctype.name)
              if item.manifestation.series_statement.nil?
                tmp_item.status_flg |= STS_INVALID_SERIAL
              end
            end

            # delimiter for call_number :default => '|'
            delimi = item.shelf.library.call_number_delimiter
            delimi = '|' if delimi.nil? || delimi.empty?

            #debug
            #p "Item #{line.strip} title  : #{item.manifestation.original_title}"
            #p "Item #{line.strip} shelf  : #{item.shelf.name}"
            #p "Item #{line.strip} library: #{item.shelf.library.name}"
            #p "delimiter: #{line.strip} is #{item.shelf.library.call_number_delimiter}"

            # if the item is deleted, set STS_DELETED
            tmp_item.status_flg |= STS_DELETED unless item.deleted_at.nil?

            # check NDC / class_type1 / class_type2
            # if call_number is empty, set STS_INVALID_CALL_NO
            call_number = item.call_number
            unless call_number.nil? || call_number.empty? then
              logger.debug "call_number: #{line.strip} => #{call_number}"
              vals = call_number.split(delimi)
              tmp_item.ndc = vals[0] if vals.length > 0
              tmp_item.class_type1 = vals[1] if vals.length > 1
              tmp_item.class_type2 = vals[2] if vals.length > 2
            else
              tmp_item.status_flg |= STS_INVALID_CALL_NO
              logger.debug "call_number is NULL or EMPTY for #{item.item_identifier}"
            end
          end
          # end_of_if item.nil?

          # SAVE tmp_item
          tmp_item.save
          seq_in_the_shelf += 1

        end
      end # enf_of_File.open
    end # end_of_File.exist
  end
  # end_of_import
  
  def self.export_error_list(out_dir)
    raise "invalid parameter: no path" if out_dir.nil? || out_dir.length < 1
    csv_file = out_dir + "error_list.csv"
    pdf_file = out_dir + "error_list.pdf"
    logger.info "output removing_list csv: #{csv_file} pdf: #{pdf_file}"
    # create output path
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
  end
  
  def self.export_pdf(dir)
    raise "invalid parameter: no path" if dir.nil? || dir.length < 1
    pdffile = dir + "resource_list.pdf"
    logger.info "output resource list : " + pdffile
    # create output path
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

 end

  def self.export(dir)
    raise "invalid parameter: no path" if dir.nil? || dir.length < 1
    csvfile = dir + "resource_list.csv"
    logger.info "output resource list : " + csvfile
    # create output path
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

    columns = [
      ['item_identifier','activerecord.attributes.item.item_identifier'],
      ['no', 'activerecord.attributes.libcheck_tmp_item.seq'],
      ['ndc', 'activerecord.attributes.libcheck_tmp_item.ndc'],
      ['class_type1', 'activerecord.attributes.libcheck_tmp_item.class_type1'],
      ['class_type2', 'activerecord.attributes.libcheck_tmp_item.class_type2'],
      [:shelf_id, 'activerecord.attributes.libcheck_tmp_item.shelf_id'],
      ['confusion_flg', 'activerecord.attributes.libcheck_tmp_item.confusion_flg'],
      [:status_notfound, 'activerecord.attributes.libcheck_tmp_item.status_notfound'],
      [:status_invalid_call_no, 'activerecord.attributes.libcheck_tmp_item.status_invalid_call_no'],
      [:status_unknown_shelf, 'activerecord.attributes.libcheck_tmp_item.status_unknown_shelf'],
      [:status_deleted, 'activerecord.attributes.libcheck_tmp_item.status_deleted'],
      [:status_diff_checkout_type, 'activerecord.attributes.libcheck_tmp_item.status_diff_checkout_type'],
      [:status_ndc_warning, 'activerecord.attributes.libcheck_tmp_item.status_ndc_warning'],
      [:status_invalid_serial, 'activerecord.attributes.libcheck_tmp_item.status_invalid_serial'],
      [:date_of_publication,'activerecord.attributes.manifestation.date_of_publication'],
      ['edition_display_value','activerecord.attributes.manifestation.edition_display_value'],
      ['original_title','activerecord.attributes.manifestation.original_title']
    ]

    File.open(csvfile, "w") do |output|

      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      output.print row.join(",")+"\n"

      item_ids = LibcheckTmpItem.find_by_sql(
                  "select id from libcheck_tmp_items order by shelf_id, no, id")
      if item_ids.nil? || item_ids.size < 1
        logger.warn "item data is empty"
      else # find data
        shelf = nil
        item_ids.each do |tid|
          item = LibcheckTmpItem.find(tid)
          if shelf.nil? || shelf.id != item.shelf_id
            shelf = LibcheckShelf.find(item.shelf_id) rescue nil
          end

          row = []
          columns.each do |column|
            case column[0]
            when :shelf_id
              row << (shelf.nil? ? "UNKNOWN":shelf.shelf_name)
            when :status_notfound
              row << conv_flg(item.status_flg, STS_NOT_FOUND)
            when :status_invalid_call_no
              row << conv_flg(item.status_flg, STS_INVALID_CALL_NO)
            when :status_unknown_shelf
              row << conv_flg(item.status_flg, STS_UNKNOWN_SHELF)
            when :status_deleted
              row << conv_flg(item.status_flg, STS_DELETED)
            when :status_diff_checkout_type
              row << conv_flg(item.status_flg, STS_CHECKOUT_T_DIFF)
            when :status_ndc_warning
              row << conv_flg(item.status_flg, STS_NDC_WARNING)
            when :status_invalid_serial
              row << conv_flg(item.status_flg, STS_INVALID_SERIAL)
            when :date_of_publication
              if item.date_of_publication.nil?
                row << ""
              else
                row << item.date_of_publication.strftime("%Y-%m-%d")
              end
            else
              row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
            end # end of case column[0]
          end #end of columns.each

          output.print '"'+row.join('","')+"\"\n"

        end # end_of item_ids.each
      end # end_of item_ids is empty?

    end # end_of File.open

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

# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportBook
    def import_book(filename, id, extraparams)
      oo = Excelx.new(filename)
      extraparams["sheet"].each_with_index do |sheet, i|
        logger.info "num=#{i}  sheet=#{sheet}"
        oo.default_sheet = sheet
        import_book_start(oo, id)
      end
    end 

    def import_book_start(oo, resource_import_textfile_id)
      num = { :manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0 }
      # setting read_area
      field_row_num = 1
      first_row_num = 2
      first_column_num = 1
      # set header field
      field = Hash.new
      first_column_num.upto(oo.last_column) do |column|
        field.store(oo.cell(field_row_num, column).to_s, column)
      end
      # check cell
      if [field[I18n.t('resource_import_textfile.excel.book.original_title')],
        field[I18n.t('resource_import_textfile.excel.book.issn_isbn')]].reject{|field| field.to_s.strip == ""}.empty?
        raise "You should specify isbn or original_tile in the first line"
      end

      first_row_num.upto(oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")
        body = []
        first_column_num.upto(oo.last_column) do |column|
          body << oo.cell(row, column)
        end
        import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => body.join("\t"))

        if oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.issn_isbn')]).present?
          #TODO: issnは?
          isbn = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.issn_isbn')]).truncate.to_s
          isbn = ISBN_Tools.cleanup(isbn)
          m = Manifestation.find_by_isbn(isbn) #TODO: issnは?
          if m
            if m.series_statement
              manifestation = m
            end
          end
        end
        num[:manifestation_found] += 1 if manifestation

        has_error = false
        unless manifestation
          #TODO: series_statement = find_series_statement(row)
          begin
            manifestation = Manifestation.import_isbn(isbn)
            if manifestation
              #manifestation.series_statement = series_statement
              manifestation.manifestation_type = ManifestationType.find(1)
              manifestation.save!
            end
          rescue EnjuNdl::InvalidIsbn
            import_textresult.error_msg = "FAIL[#{row}]: "+I18n.t('resource_import_file.invalid_isbn', :isbn => isbn)
            Rails.logger.error "FAIL[#{row}]: import_isbn catch EnjuNdl::InvalidIsbn isbn: #{isbn}"
            manifestation = nil
            num[:failed] += 1
            has_error = true
          rescue EnjuNdl::RecordNotFound
            import_textresult.error_msg = "FAIL[#{row}]: "+I18n.t('resource_import_file.record_not_found', :isbn => isbn)
            Rails.logger.error "FAIL[#{row}]: import_isbn catch EnjuNdl::RecordNotFound isbn: #{isbn}"
            manifestation = nil
            num[:failed] += 1
            has_error = true
          rescue ActiveRecord::RecordInvalid  => e
            import_textresult.error_msg = "FAIL[#{row}]: fail save manifestation. (record invalid) #{e.message}"
            Rails.logger.error "FAIL[#{row}]: fail save manifestation. (record invalid) #{e.message}"
            Rails.logger.error "FAIL[#{row}]: #{$@}"
            manifestation = nil
            num[:failed] += 1
            has_error = true
          rescue ActiveRecord::StatementInvalid => e
            import_textresult.error_msg = "FAIL[#{row}]: fail save manifestation. (statement invalid) #{e.message}"
            Rails.logger.error "FAIL[#{row}]: fail save manifestation. (statement invalid) #{e.message}"
            Rails.logger.error "FAIL[#{row}]: #{$@}"
            manifestation = nil
            num[:failed] += 1
            has_error = true
          rescue => e
            import_textresult.error_msg = "FAIL[#{row}]: fail save manifestation. #{e.message}"
            Rails.logger.error "FAIL[#{row}]: fail save manifestation. #{e.message}"
            Rails.logger.error "FAIL[#{row}]: #{$@}"
            manifestation = nil
            num[:failed] += 1
            has_error = true
          end
          num[:manifestation_imported] += 1 if manifestation
        end

        unless has_error
          begin
            unless manifestation
              manifestation = fetch_book(oo, row, field)
              num[:manifestation_imported] += 1 if manifestation
            end
            import_textresult.manifestation = manifestation
            if manifestation.valid?
              resource_import_textfile = ResourceImportTextfile.find(resource_import_textfile_id)
              items_num = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.items_num')]).truncate
              books = []
              original_book = ""
              items_num.times do |i|
                #import_textresult.items << create_book_item(oo, row, field, manifestation,resource_import_textfile, i)
                book = create_book_item(oo, row, field, manifestation,resource_import_textfile, i)
                books << book
                original_book = book if book.rank == 0
                num[:item_imported] += 1
              end
              import_textresult.item = original_book
              manifestation.index

#TODO:itemsに変更すること
              if import_textresult.item
                current_user = User.where(:username => 'admin').first
                msg = []
              #  import_textresult.items.each do |item|
                  if import_textresult.item.manifestation.next_reserve and import_textresult.item.item_identifier
                    import_textresult.item.retain(current_user) if import_textresult.item.available_for_retain?
                    msg << I18n.t('resource_import_file.reserved_item',
                      :username => import_textresult.item.reserve.user.username,
                      :user_number => import_textresult.item.reserve.user.user_number)
                  end
             #   end
                import_textresult.error_msg = msg.join ("\s\n")
              end
            else
              num[:failed] += 1
            end
          rescue => e
            import_textresult.error_msg = "FAIL[#{row}]: #{e.message}"
            Rails.logger.info("FAIL[#{row} resource registration failed: column #{row}: #{e.message}")
            Rails.logger.info("FAIL[#{row} #{$@}")
            num[:failed] += 1
          end
        end
        import_textresult.save!

        if row % 50 == 0
          Sunspot.commit
          GC.start
        end
      end
      #sm_complete!
      Rails.cache.write("manifestation_search_total", Manifestation.search.total)
      return num
    end

    def fetch_book(oo, row, field)
      manifestation = nil
      # 更新、削除はどうする？
      title = {}
      title[:original_title] = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.original_title')]).to_s.strip
#TODO:wrong
#    if ISBN_Tools.is_valid?(oo.cell(row, field[I18n.t('resource_import_textfile.excel.issn_isbn')]).truncate.to_s.strip)
#      isbn = ISBN_Tools.cleanup(oo.cell(row, field[I18n.t('resource_import_textfile.excel.issn_isbn')]).truncate.to_s.strip)
#    end

      ResourceImportTextfile.transaction do
        begin
          manifestation = Manifestation.new(title)
          manifestation.required_role = Role.find('Guest')
          manifestation.note = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.note')]).to_s.strip
          manifestation.during_import = true
          manifestation.manifestation_type = ManifestationType.find(1) #TODO 受入種別を設定する

          frequency_dispname = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.frequency')]).to_s.strip
          frequency = Frequency.where(:display_name => frequency_dispname).first
          manifestation.frequency = frequency if frequency

          creators = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.creator')]).to_s.strip.split('；')
          creators_list = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
          creator_patrons = Patron.import_patrons(creators_list)
          manifestation.creators << creator_patrons

          manifestation.save!
          return manifestation
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def create_book_item(oo, row, field, manifestation, resource_import_textfile, count)
      circulation_status = CirculationStatus.where(:name => 'Available On Shelf').first

      shelf = select_item_shelf(resource_import_textfile.user)

      bookstore_name = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.bookstore')]).to_s
      bookstore = Bookstore.import_bookstore(bookstore_name)

      rank = 2;
      case count
      when 0
        rank = 0
      when 1
        rank = 1
      end

      item = import_item(manifestation, {
        :circulation_status => circulation_status,
        :shelf => shelf,
        :acquired_at =>  oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.accept_at')]).to_s.strip,
        :bookstore => bookstore,
        :item_identifier => "#{Time.now.instance_eval { '%s%03d' % [strftime('%Y%m%d%H%M%S'), (usec / 1000.0).round] }}_#{count}", #TODO:
        :rank => rank.to_i,
      })
      return item
    end
  end
end

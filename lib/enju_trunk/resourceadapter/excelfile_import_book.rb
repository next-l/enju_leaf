# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportBook
    def import_book(filename, id, extraparams)
      manifestation_type = ManifestationType.find(eval(extraparams['manifestation_type']).to_i)

      oo = Excelx.new(filename)
      extraparams["sheet"].each_with_index do |sheet, i|
        logger.info "num=#{i}  sheet=#{sheet}"
        oo.default_sheet = sheet
        import_book_start(oo, id, manifestation_type)
      end
    end 

    def import_book_start(oo, resource_import_textfile_id, manifestation_type)
      num = { :manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0 }
      # setting read_area
      field_row_num = 1
      first_row_num = 2
      first_column_num = 1
      # set header field
      field = Hash.new
      first_column_num.upto(oo.last_column) do |column|
        field.store(oo.cell(field_row_num, column).to_s.strip, column)
      end
      # check cell
      if [field[I18n.t('resource_import_textfile.excel.book.original_title')],
        field[I18n.t('resource_import_textfile.excel.book.isbn')]].reject{|field| field.to_s.strip == ""}.empty?
        raise "You should specify isbn or original_tile in the first line"
      end

      first_row_num.upto(oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")
        body = []
        first_column_num.upto(oo.last_column) do |column|
          body << oo.cell(row, column)
        end
        import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => body.join("\t"))
        has_error = false

        # check exsit isbn or original_title
        if [oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.original_title')]).to_s.strip,
          oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.isbn')]).to_s.strip].reject{|field| field.to_s.strip == ""}.empty?
          import_textresult.error_msg = "FAIL[#{row}] #{I18n.t('resource_import_textfile.error.book.original_title_and_isbn_is_blank')}"
          has_error = true
        end

#TODO　ISBNの処理を後で作成すること
        if oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.isbn')]).present?
          #TODO: issnは?
          #TODO isbnの処理はあとで
          isbn = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.isbn')]).truncate.to_s
          isbn = ISBN_Tools.cleanup(isbn)
          m = Manifestation.find_by_isbn(isbn) #TODO: issnは?
          if m
            if m.series_statement
              manifestation = m
            end
          end
        end
        num[:manifestation_found] += 1 if manifestation

        unless manifestation
          #TODO: series_statement = find_series_statement(row)
          begin
            manifestation = Manifestation.import_isbn(isbn)
            if manifestation
              #manifestation.series_statement = series_statement
              manifestation.manifestation_type = manifestation_type
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
              manifestation = fetch_book(oo, row, field, manifestation_type)
              num[:manifestation_imported] += 1 if manifestation
            end
            import_textresult.manifestation = manifestation
            if manifestation.valid?
              resource_import_textfile = ResourceImportTextfile.find(resource_import_textfile_id)
              import_textresult.item = create_book_item(oo, row, field, manifestation,resource_import_textfile)
              manifestation.index
              num[:item_imported] += 1 if import_textresult.item

              if import_textresult.item.manifestation.next_reserve
                current_user = User.where(:username => 'admin').first
                msg = []
                if import_textresult.item.manifestation.next_reserve and import_textresult.item.item_identifier
                  import_textresult.item.retain(current_user) if import_textresult.item.available_for_retain?
                  msg << I18n.t('resource_import_file.reserved_item',
                    :username => import_textresult.item.reserve.user.username,
                    :user_number => import_textresult.item.reserve.user.user_number)
                end
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

    def fetch_book(oo, row, field, manifestation_type)
      manifestation = nil
      # 更新、削除はどうする？
      title = {}
      title[:original_title] = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.original_title')]).to_s.strip
      title[:title_transcription] = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.title_transcription')]).to_s.strip
      title[:title_alternative] = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.title_alternative')]).to_s.strip

#TODO:wrong
#     if ISBN_Tools.is_valid?(oo.cell(row, field[I18n.t('resource_import_textfile.excel.issn_isbn')]).truncate.to_s.strip)
#       isbn = ISBN_Tools.cleanup(oo.cell(row, field[I18n.t('resource_import_textfile.excel.issn_isbn')]).truncate.to_s.strip)
#     end

      # must be checked field
      carrier_type_field  = field[I18n.t('resource_import_textfile.excel.book.carrier_type')] || nil
      frequency_field     = field[I18n.t('resource_import_textfile.excel.book.frequency')] || nil
      pub_date_field      = field[I18n.t('resource_import_textfile.excel.book.pub_date')] || nil
      language_field      = field[I18n.t('resource_import_textfile.excel.book.language')] || nil 
      edition_field       = field[I18n.t('resource_import_textfile.excel.book.edition')] || nil
      height_field        = field[I18n.t('resource_import_textfile.excel.book.height')] || nil
      width_field         = field[I18n.t('resource_import_textfile.excel.book.width')] || nil
      depth_field         = field[I18n.t('resource_import_textfile.excel.book.depth')] || nil
      price_field         = field[I18n.t('resource_import_textfile.excel.book.price')] || nil
      required_role_field = field[I18n.t('resource_import_textfile.excel.book.required_role')] || nil

      ResourceImportTextfile.transaction do
        begin
          manifestation                      = Manifestation.new(title)
          manifestation.manifestation_type   = manifestation_type
          manifestation.place_of_publication = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.place_of_publication')]).to_s.strip
          manifestation.carrier_type         = set_data(CarrierType, oo.cell(row, carrier_type_field).to_s.strip, false, 'carrier_type', 'print')
          manifestation.frequency            = set_data(Frequency, oo.cell(row, frequency_field).to_s.strip, false, 'frequency', '不明', :display_name)
          manifestation.pub_date             = fix_data(oo.cell(row, pub_date_field).to_s.strip)
          manifestation.language             = set_data(Language, oo.cell(row, language_field).to_s.strip, false, 'language', 'Japanese')
          manifestation.edition              = check_data_is_integer(oo.cell(row, edition_field).to_s.strip, 'edition')
          manifestation.volume_number_string = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.volume_number_string')]).to_s.strip)
          manifestation.issue_number_string  = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.issue_number_string')]).to_s.strip)
          manifestation.start_page           = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.start_page')]).to_s.strip).to_s 
          manifestation.end_page             = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.end_page')]).to_s.strip).to_s
          manifestation.height               = check_data_is_numeric(oo.cell(row, height_field).to_s.strip, 'height')
          manifestation.width                = check_data_is_numeric(oo.cell(row, width_field).to_s.strip, 'width')
          manifestation.depth                = check_data_is_numeric(oo.cell(row, depth_field).to_s.strip, 'depth')
          manifestation.price                = check_data_is_integer(oo.cell(row, price_field).to_s.strip, 'price')
          manifestation.access_address       = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.access_address')]).to_s.strip
          manifestation.repository_content   = fix_boolean(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.repository_content')]).to_s.strip)
          manifestation.required_role        = set_data(Role, oo.cell(row,required_role_field).to_s.strip, false, 'required_role', 'Guest')
          manifestation.except_recent        = fix_boolean(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.except_recent')]).to_s.strip)
          manifestation.description          = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.description')]).to_s.strip
          manifestation.supplement           = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.supplement')]).to_s.strip
          manifestation.note                 = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.note')]).to_s.strip
          manifestation.during_import        = true
=begin
          # creator
          creators = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.creator')]).to_s.strip.split('；')
          creators_list = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
          creator_patrons = Patron.import_patrons(creators_list)
          manifestation.creators << creator_patrons
          # contributor
          contributors = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.contributor')]).to_s.strip.split('；')
          contributors_list = contributors.inject([]){ |list, contributor| list << {:full_name => contributor.to_s.strip, :full_name_transcription => "" } }
          contributor_patrons = Patron.import_patrons(contributors_list)
          manifestation.contributors << contributor_patrons
          # publisher
          publishers = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.publisher')]).to_s.strip.split('；')
          publishers_list = publishers.inject([]){ |list, publisher| list << {:full_name => publisher.to_s.strip, :full_name_transcription => "" } }
          publisher_patrons = Patron.import_patrons(publishers_list)
          manifestation.publishers << publisher_patrons
=end
          manifestation.save!

          return manifestation
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def create_book_item(oo, row, field, manifestation, resource_import_textfile)
      accept_type_field        = field[I18n.t('resource_import_textfile.excel.book.accept_type')] || nil
      acquired_at_field        = field[I18n.t('resource_import_textfile.excel.book.acquired_at')] || nil
      shelf_field              = field[I18n.t('resource_import_textfile.excel.book.shelf')] || nil
      checkout_type_field      = field[I18n.t('resource_import_textfile.excel.book.checkout_type')] || nil
      circulation_status_field = field[I18n.t('resource_import_textfile.excel.book.circulation_status')] || nil
      retention_period_field   = field[I18n.t('resource_import_textfile.excel.book.retention_period')] || nil
      price_field              = field[I18n.t('resource_import_textfile.excel.book.item_price')] || nil
      use_restriction_field    = field[I18n.t('resource_import_textfile.excel.book.use_restriction')] || nil
      required_role_field      = field[I18n.t('resource_import_textfile.excel.book.required_role')] || nil
     
      options = {
        :accept_type         => set_data(AcceptType, oo.cell(row, accept_type_field).to_s.strip, true, 'accept_type', '', :display_name),
        :acquired_at         => check_data_is_date(oo.cell(row, acquired_at_field).to_s.strip, 'acquired_at'),
        :shelf               => select_item_shelf(oo.cell(row, shelf_field).to_s.strip, resource_import_textfile.user),
        :checkout_type       => set_data(CheckoutType, oo.cell(row, checkout_type_field).to_s.strip, false, 'checkout_type', 'book'),
        :circulation_status  => set_data(CirculationStatus, oo.cell(row, circulation_status_field).to_s.strip, false, 'circulation_status', 'In Process'),
        :retention_period    => set_data(RetentionPeriod, oo.cell(row, retention_period_field).to_s.strip, false, 'retention_period', '永年', :display_name),
        :call_number         => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.call_number')]).to_s.strip),
        :price               => check_data_is_integer(oo.cell(row, price_field).to_s.strip, 'item_price'),
        :url                 => oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.url')]).to_s.strip,
        :include_supplements => fix_boolean(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.include_supplements')]).to_s.strip),
        :use_restriction_id  => fix_use_restriction(oo.cell(row, use_restriction_field).to_s.strip),
        :note                => oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.item_note')]).to_s.strip,
        :rank                => fix_rank(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.rank')]).to_s.strip),
        :required_role       => set_data(Role, oo.cell(row, required_role_field).to_s.strip, false, 'required_role', 'Guest'),
        :item_identifier     => Numbering.do_numbering('book'),
      }

      # bookstore
      bookstore_name = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.bookstore')]).to_s.strip
      bookstore = Bookstore.import_bookstore(bookstore_name) rescue nil
      options[:bookstore] = bookstore unless bookstore.nil?

      item = import_item(manifestation, options)
      return item
    end

    def fix_use_restriction(cell)
      unless cell.size == 0 or cell.upcase == 'FALSE'
        return UseRestriction.where(:name => 'Not For Loan').select(:id)
      end
      return UseRestriction.where(:name => 'Limited Circulation, Normal Loan Period').select(:id)     
    end

    def fix_rank(cell)
      case cell
      when '', I18n.t('item.original')
        return 0
      when I18n.t('item.copy')
        return 1
      when I18n.t('item.spare')
        return 2
      else
        raise I18n.t('resource_import_textfile.error.book.wrong_rank', :data => cell) 
      end
    end
  end
end

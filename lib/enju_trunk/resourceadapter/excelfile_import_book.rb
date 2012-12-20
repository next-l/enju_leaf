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
      first_row_num = 2
      first_column_num = 1
      field = set_field(oo, first_row_num, first_column_num)
      # check field
      raise unless has_necessary_field?(oo, field, manifestation_type, resource_import_textfile_id)

      first_row_num.upto(oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")
        has_error = false

        body = []
        first_column_num.upto(oo.last_column) do |column|
          body << oo.cell(row, column)
        end
        import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => body.join("\t"))
        # check exist isbn or original_title
        next unless has_necessary_cell?(oo, field, row, manifestation_type, import_textresult)

        unless has_error
          begin
            manifestation = fetch_book(oo, row, field, manifestation_type)
            num[:manifestation_imported] += 1 if manifestation
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

    def exist_same_book?(oo, row, field, manifestation_type, manifestation)
      original_title = manifestation.original_title
      pub_date       = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.pub_date')]).to_s.strip).to_s
      creators       = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.creator')]).to_s.strip).split(';')
      publishers     = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.publisher')]).to_s.strip).split(';')

      book = nil
      unless manifestation_type.is_series?
        book = Manifestation.find(
          :first,
          :include => [:creators, :publishers],
          :conditions => { :original_title => original_title, :pub_date => pub_date }
        ) rescue nil
      else
        series_title = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.series.original_title')]).to_s.strip).to_s
        book = Manifestation.find(
          :first,
          :joins => :series_statement,
          :include => [:creators, :publishers],
          :conditions => { :original_title => original_title, :pub_date => pub_date, :series_statements => { :original_title => series_title } }
        ) rescue nil 
      end
      if book
        if book.creators.map{ |c| c.full_name }.sort == creators.sort and book.publishers.map{ |s| s.full_name }.sort == publishers.sort
          unless manifestation_type.is_series?
            raise I18n.t('resource_import_textfile.error.book.exist_same_book')
          else
            raise I18n.t('resource_import_textfile.error.series.exist_same_book')
          end
        end
      end
      return book
    end

    def fetch_book(oo, row, field, manifestation_type)
      manifestation = nil
      isbn = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.isbn')]).to_s.strip).to_s
      unless isbn.blank?
        isbn = ISBN_Tools.cleanup(isbn)
        begin
          manifestation = Manifestation.import_isbn(isbn)
          raise I18n.t('resource_import_textfile.error.book.wrong_isbn') unless manifestation
        rescue EnjuNdl::InvalidIsbn
          raise I18n.t('resource_import_textfile.error.book.wrong_isbn')
        rescue EnjuNdl::RecordNotFound
          raise I18n.t('resource_import_textfile.error.book.wrong_isbn')
        end
      end
      isbn = ISBN_Tools.cleanup(isbn) if ISBN_Tools.is_valid?(isbn)
      # must be checked field
      original_title_field      = field[I18n.t('resource_import_textfile.excel.book.original_title')] || nil
      title_transcription_field = field[I18n.t('resource_import_textfile.excel.book.title_transcription')] || nil
      title_alternative_field   = field[I18n.t('resource_import_textfile.excel.book.title_alternative')] || nil
      carrier_type_field        = field[I18n.t('resource_import_textfile.excel.book.carrier_type')] || nil
      pub_date_field            = field[I18n.t('resource_import_textfile.excel.book.pub_date')] || nil
      language_field            = field[I18n.t('resource_import_textfile.excel.book.language')] || nil 
      edition_field             = field[I18n.t('resource_import_textfile.excel.book.edition')] || nil
      height_field              = field[I18n.t('resource_import_textfile.excel.book.height')] || nil
      width_field               = field[I18n.t('resource_import_textfile.excel.book.width')] || nil
      depth_field               = field[I18n.t('resource_import_textfile.excel.book.depth')] || nil
      price_field               = field[I18n.t('resource_import_textfile.excel.book.price')] || nil
      required_role_field       = field[I18n.t('resource_import_textfile.excel.book.required_role')] || nil

      ResourceImportTextfile.transaction do
        begin
          title = {}
          title[:original_title]      = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.original_title')]).to_s.strip).to_s
          title[:title_transcription] = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.title_transcription')]).to_s.strip).to_s
          title[:title_alternative]   = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.title_alternative')]).to_s.strip).to_s
          if manifestation.nil?
            manifestation = Manifestation.new(title)
          else
            manifestation.original_title      = title[:original_title] unless title[:original_title].blank?
            manifestation.title_transcription = title[:title_transcription] unless title[:title_transcription].blank?
            manifestation.title_alternative   = title[:title_alternative] unless title[:title_alternative].blank?
          end
          exist_same_book?(oo, row, field, manifestation_type, manifestation)

          params = {
            :manifestation_type   => manifestation_type,
            :place_of_publication => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.place_of_publication')]).to_s.strip).to_s,
            :carrier_type         => set_data(CarrierType, oo.cell(row, carrier_type_field).to_s.strip, false, 'carrier_type', 'print'),
            :frequency            => set_frequency(oo, row, field, manifestation_type),
            :pub_date             => fix_data(oo.cell(row, pub_date_field).to_s.strip),
            :language             => set_data(Language, oo.cell(row, language_field).to_s.strip, false, 'language', 'Japanese'),
            :isbn                 => isbn,
            :lccn                 => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.lccn')]).to_s.strip).to_s,
            :edition              => check_data_is_integer(oo.cell(row, edition_field).to_s.strip, 'edition'),
            :volume_number_string => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.volume_number_string')]).to_s.strip),
            :issue_number_string  => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.issue_number_string')]).to_s.strip),
            :start_page           => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.start_page')]).to_s.strip).to_s,
            :end_page             => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.end_page')]).to_s.strip).to_s,
            :height               => check_data_is_numeric(oo.cell(row, height_field).to_s.strip, 'height'),
            :width                => check_data_is_numeric(oo.cell(row, width_field).to_s.strip, 'width'),
            :depth                => check_data_is_numeric(oo.cell(row, depth_field).to_s.strip, 'depth'),
            :price                => check_data_is_integer(oo.cell(row, price_field).to_s.strip, 'price'),
            :access_address       => oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.access_address')]).to_s.strip,
            :repository_content   => fix_boolean(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.repository_content')]).to_s.strip),
            :except_recent        => fix_boolean(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.except_recent')]).to_s.strip),
            :description          => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.description')]).to_s.strip).to_s,
            :supplement           => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.supplement')]).to_s.strip).to_s,
            :note                 => fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.note')]).to_s.strip).to_s, 
            :required_role        => set_data(Role, oo.cell(row,required_role_field).to_s.strip, false, 'required_role', 'Guest'),
          }
          #TODO:createrより後でmanifestationがつくられる場合があるので先にsaveしておく
          manifestation.update_attributes!(params.merge(:during_import => true))
          # creator
          creators = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.creator')]).to_s.strip.split(';')
          creators_list = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
          creator_patrons = Patron.import_patrons(creators_list)
          manifestation.creators << creator_patrons
          # contributor
          contributors = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.contributor')]).to_s.strip.split(';')
          contributors_list = contributors.inject([]){ |list, contributor| list << {:full_name => contributor.to_s.strip, :full_name_transcription => "" } }
          contributor_patrons = Patron.import_patrons(contributors_list)
          manifestation.contributors << contributor_patrons
          # publisher
          publishers = oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.publisher')]).to_s.strip.split(';')
          publishers_list = publishers.inject([]){ |list, publisher| list << {:full_name => publisher.to_s.strip, :full_name_transcription => "" } }
          publisher_patrons = Patron.import_patrons(publishers_list)
          manifestation.publishers << publisher_patrons
          # subject
          subjects_list = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.subject')]).to_s.strip).to_s.split(';')
          subjects = Subject.import_subjects (subjects_list)
          manifestation.subjects << subjects

          series_statement = import_series_statement(oo, row, field, manifestation_type)
          manifestation.series_statement = series_statement if series_statement

          manifestation.save!
          return manifestation
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def import_series_statement(oo, row, field, manifestation_type)
      issn = ISBN_Tools.cleanup(fix_data(oo.cell(row,field[I18n.t('resource_import_textfile.excel.series.issn')]).to_s.strip).to_s)
      series_statement = find_series_statement(oo, row, field)

      unless series_statement
        if oo.cell(row, field[I18n.t('resource_import_textfile.excel.series.original_title')]).to_s.strip.present?
          original_title_field      = field[I18n.t('resource_import_textfile.excel.series.original_title')] || nil
          title_transcription_field = field[I18n.t('resource_import_textfile.excel.series.title_transcription')] || nil

          series_statement = SeriesStatement.new(
            :original_title        => fix_data(oo.cell(row, original_title_field).to_s.strip).to_s,
            :title_transcription   => fix_data(oo.cell(row, title_transcription_field).to_s.strip).to_s,
            :periodical            => fix_boolean(oo.cell(row, field[I18n.t('resource_import_textfile.excel.series.periodical')]).to_s.strip),
          )
          series_statement.issn = issn if issn.present?
          series_statement.save!
        end
      end
      return series_statement if series_statement
      return nil
    end

    def find_series_statement(oo, row, field)
      issn = ISBN_Tools.cleanup(fix_data(oo.cell(row,field[I18n.t('resource_import_textfile.excel.series.issn')]).to_s.strip).to_s)
      series_statement = SeriesStatement.where(:issn => issn).first if issn.present?
      unless series_statement
        original_title_field = field[I18n.t('resource_import_textfile.excel.series.original_title')] || nil
        original_title = fix_data(oo.cell(row, original_title_field).to_s.strip).to_s || nil
        series_statement = SeriesStatement.where(:original_title => original_title).first
      end
      if series_statement
        return series_statement
      end
      return nil
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

    def set_field(oo, first_row_num, first_column_num)
      field_row_num = 1

      # set header field
      field = Hash.new
      first_column_num.upto(oo.last_column) do |column|
        field.store(oo.cell(field_row_num, column).to_s.strip, column)
      end
      return field
    end

    def set_frequency(oo, row, field, manifestation_type)
      frequency = nil
#      frequency_series_field = field[I18n.t('resource_import_textfile.excel.series.frequency')] || nil
      frequency_book_field   = field[I18n.t('resource_import_textfile.excel.book.frequency')] || nil
#      if manifestation_type.is_series?
#        unless oo.cell(row, frequency_book_field).to_s.strip.blank?
#          frequency = set_data(Frequency, oo.cell(row, frequency_book_field).to_s.strip, false, 'frequency', '不明', :display_name)
#        else
#          frequency = set_data(Frequency, oo.cell(row, frequency_series_field).to_s.strip, false, 'frequency', '不明', :display_name)
#        end
#      else
        frequency = set_data(Frequency, oo.cell(row, frequency_book_field).to_s.strip, false, 'frequency', '不明', :display_name)
#      end
      return frequency
    end

    def has_necessary_field?(oo, field, manifestation_type, resource_import_textfile_id)
      require_head_book   = [field[I18n.t('resource_import_textfile.excel.book.original_title')],
                             field[I18n.t('resource_import_textfile.excel.book.isbn')]]
      require_head_series = [field[I18n.t('resource_import_textfile.excel.series.original_title')],
                             field[I18n.t('resource_import_textfile.excel.series.issn')]]

      if manifestation_type.is_book?
        if require_head_book.reject{ |f| f.to_s.strip == "" }.empty?
          import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => '' )
          import_textresult.error_msg = I18n.t('resource_import_textfile.error.series.head_is_blank', :sheet => oo.default_sheet)
          import_textresult.save 
          return false
        end
      else
        if require_head_series.reject{ |f| f.to_s.strip == "" }.empty? or require_head_book.reject{ |f| f.to_s.strip == "" }.empty?
          import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => '' )
          import_textresult.error_msg = I18n.t('resource_import_textfile.error.series.head_is_blank', :sheet => oo.default_sheet)
          import_textresult.save 
          return false
        end
      end
      true
    end

    def has_necessary_cell?(oo, field, row, manifestation_type, import_textresult)
      require_cell_book   = [oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.original_title')]).to_s.strip,
                             oo.cell(row, field[I18n.t('resource_import_textfile.excel.book.isbn')]).to_s.strip]
      require_cell_series = [oo.cell(row, field[I18n.t('resource_import_textfile.excel.series.original_title')]).to_s.strip,
                             oo.cell(row, field[I18n.t('resource_import_textfile.excel.series.issn')]).to_s.strip]
      if manifestation_type.is_book?  
        if require_cell_book.reject{ |f| f.to_s.strip == "" }.empty?
          import_textresult.error_msg = "FAIL[sheet:#{oo.default_sheet} row:#{row}] #{I18n.t('resource_import_textfile.error.book.cell_is_blank')}"
          import_textresult.save
          return false
        end
      else
        if require_cell_series.reject{ |f| f.to_s.strip == "" }.empty? or require_cell_book.reject{ |f| f.to_s.strip == "" }.empty?
          import_textresult.error_msg = "FAIL[sheet:#{oo.default_sheet} row:#{row}] #{I18n.t('resource_import_textfile.error.series.cell_is_blank')}"
          import_textresult.save
          return false
        end 
      end
      true
    end
  end
end

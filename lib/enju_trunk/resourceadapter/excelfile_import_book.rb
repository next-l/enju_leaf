# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportBook
    def import_book(filename, id, extraparams)
      @manifestation_type = ManifestationType.find(extraparams['manifestation_type'].to_i)
      @textfile_id = id
      @oo = Excelx.new(filename)
      errors = []

      extraparams["sheet"].each_with_index do |sheet, i|
        logger.info "num=#{i}  sheet=#{sheet}"
        @oo.default_sheet = sheet

        error_msg = check_header_field(sheet)
        unless error_msg
          import_textresult = ResourceImportTextresult.new(
            :resource_import_textfile_id => @textfile_id,
            :extraparams                 => "{'sheet'=>'#{sheet}'}",
            :body                        => @field.keys.join("\t"),
            :error_msg                   => I18n.t('resource_import_textfile.message.read_sheet', :sheet => sheet),
            :failed                      => true
          )
          import_textresult.save! 
          import_book_data(sheet)
        else
          errors << { :msg => error_msg, :sheet => sheet }
        end
      end
      if errors.size > 0
        errors.each do |error|
          import_textresult = ResourceImportTextresult.new(
            :resource_import_textfile_id => @textfile_id,
            :extraparams                 => "{'sheet'=>'#{error[:sheet]}', 'wrong_sheet' => true, 'filename' => '#{filename}' }",
            :error_msg                   => error[:msg], 
            :failed                      => true
           )
          import_textresult.save!
        end
      end
    end 

    def check_header_field(sheet)
      field_row_num = 1

      # read the field, then set field a hash
      @field = Hash::new
      columns_num = 0
      begin
        @oo.first_column.upto(@oo.last_column) do |column|
          name = @oo.cell(field_row_num, column).to_s.strip
          unless name.blank?
            @field.store(name, column) 
            columns_num = columns_num + 1
          end
        end
      rescue
        return I18n.t('resource_import_textfile.error.blank_sheet', :sheet => sheet)
      end
      if (columns_num - @field.keys.uniq.size) > 0
        return I18n.t('resource_import_textfile.error.overlap', :sheet => sheet)
      end
      # exist need fields?
      import_textresult = ResourceImportTextresult.new(:resource_import_textfile_id => @textfile_id, :extraparams => "{'sheet'=>'#{sheet}'}" )
      require_book = [@field[I18n.t('resource_import_textfile.excel.book.original_title')],
                      @field[I18n.t('resource_import_textfile.excel.book.isbn')]]
      require_series = [@field[I18n.t('resource_import_textfile.excel.series.original_title')],
                        @field[I18n.t('resource_import_textfile.excel.series.issn')]]
      if @manifestation_type.is_book?
        if require_book.reject{ |field| field.to_s.strip == "" }.empty?
          return I18n.t('resource_import_textfile.error.book.head_is_blank', :sheet => sheet)
        end
      else
        if require_series.reject{ |f| f.to_s.strip == "" }.empty? and require_book.reject{ |f| f.to_s.strip == "" }.empty?
          return I18n.t('resource_import_textfile.message.read_sheet', :sheet => sheet)
        end
      end
      return nil
    end

    def import_book_data(sheet)
      first_data_row_num = 2
      num = { 
       :manifestation_imported => 0,
       :item_imported          => 0,
       :manifestation_found    => 0,
       :item_found             => 0,
       :failed                 => 0 
      }

      first_data_row_num.upto(@oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")

        datas = Hash::new
        @oo.first_column.upto(@oo.last_column) do |column|
          datas.store(column, fix_data(@oo.cell(row, column).to_s.strip))
        end

        import_textresult = ResourceImportTextresult.new(
          :resource_import_textfile_id => @textfile_id,
          :body => datas.values.join("\t"),
          :extraparams => "{'sheet'=>'#{sheet}'}"
        )
        next unless has_necessary_cell?(datas, sheet, row, import_textresult)
        begin
          ActiveRecord::Base.transaction do
            if fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.del_flg')]])
              delete_data(datas) 
            else
              item = nil
              item_identifier = datas[@field[I18n.t('resource_import_textfile.excel.book.item_identifier')]]
              item = Item.where(:item_identifier => item_identifier.to_s).first unless item_identifier.nil? or item_identifier.to_s == ""
              manifestation = fetch_book(datas, item)
              if manifestation.valid?
                item = create_book_item(datas, manifestation, item)
                import_textresult.manifestation = manifestation
                import_textresult.item = item
                manifestation.index
                num[:manifestation_imported] += 1 if import_textresult.manifestation
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
            end
          end
        rescue => e
          import_textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}]: #{e.message}"
          import_textresult.failed = true
          Rails.logger.info("FAIL[sheet:#{sheet} #{row} resource registration failed: column #{row}: #{e.message}")
          Rails.logger.info("FAIL[sheet:#{sheet} #{row} #{$@}")
          num[:failed] += 1
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

    def fetch_book(datas, item = nil)
      @mode = 'create'
      manifestation = nil

      if item
        manifestation = item.manifestation
        @mode == 'create'
      else
        isbn = datas[@field[I18n.t('resource_import_textfile.excel.book.isbn')]].to_s
        manifestation = import_isbn(isbn)
        series_statement = @manifestation_type.is_series? ? import_series_statement(datas, manifestation) : nil

        manifestation = exist_same_book?(datas, manifestation, series_statement) 
      end
      unless manifestation
        manifestation = Manifestation.new
      end

      manifestation.series_statement = series_statement if series_statement
      original_title       = datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]]
      title_transcription  = datas[@field[I18n.t('resource_import_textfile.excel.book.title_transcription')]]
      title_alternative    = datas[@field[I18n.t('resource_import_textfile.excel.book.title_alternative')]]
      carrier_type         = set_data(datas, CarrierType, 'carrier_type', { :default => 'print' })
      frequency            = set_data(datas, Frequency, 'frequency', { :default => '不明', :check_column => :display_name })
      pub_date             = datas[@field[I18n.t('resource_import_textfile.excel.book.pub_date')]]
      place_of_publication = datas[@field[I18n.t('resource_import_textfile.excel.book.place_of_publication')]]
      language             = set_data(datas, Language, 'language', { :default => 'Japanese' })
      edition              = datas[@field[I18n.t('resource_import_textfile.excel.book.edition_display_value')]]
      volume_number_string = datas[@field[I18n.t('resource_import_textfile.excel.book.volume_number_string')]]
      issue_number_string  = datas[@field[I18n.t('resource_import_textfile.excel.book.issue_number_string')]]
      issn                 = datas[@field[I18n.t('resource_import_textfile.excel.series.issn')]]
      lccn                 = datas[@field[I18n.t('resource_import_textfile.excel.book.lccn')]]
      marc_number          = datas[@field[I18n.t('resource_import_textfile.excel.book.marc_number')]]
      ndc                  = datas[@field[I18n.t('resource_import_textfile.excel.book.ndc')]]
      start_page           = datas[@field[I18n.t('resource_import_textfile.excel.book.start_page')]]
      end_page             = datas[@field[I18n.t('resource_import_textfile.excel.book.end_page')]]
      height               = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.height')]], 'height')
      width                = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.width')]], 'width') 
      depth                = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.depth')]], 'depth')
      price                = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.price')]], 'price')
      access_address       = datas[@field[I18n.t('resource_import_textfile.excel.book.access_address')]]
      acceptance_number    = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.acceptance_number')]], 'acceptance_number')
      repository_content   = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.repository_content')]])
      required_role        = set_data(datas, Role, 'required_role', { :default => 'Guest' })
      except_recent        = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.except_recent')]])
      description          = datas[@field[I18n.t('resource_import_textfile.excel.book.description')]]
      supplement           = datas[@field[I18n.t('resource_import_textfile.excel.book.supplement')]]
      note                 = datas[@field[I18n.t('resource_import_textfile.excel.book.note')]]
      missing_issue        = set_missing_issue(datas[@field[I18n.t('resource_import_textfile.excel.book.missing_issue')]])

      manifestation.manifestation_type   = @manifestation_type
      manifestation.original_title       = original_title.to_s       unless original_title.nil?
      manifestation.title_transcription  = title_transcription.to_s  unless title_transcription.nil?
      manifestation.title_alternative    = title_alternative.to_s    unless title_alternative.nil?
      manifestation.carrier_type         = carrier_type              unless carrier_type.nil?
      manifestation.frequency            = frequency                 unless frequency.nil?
      manifestation.pub_date             = pub_date.to_s             unless pub_date.nil?
      manifestation.place_of_publication = place_of_publication.to_s unless place_of_publication.nil?
      manifestation.language             = language                  unless language.nil?
      manifestation.edition_display_value= edition                   unless edition.nil?
      manifestation.volume_number_string = volume_number_string.to_s unless volume_number_string.nil?
      manifestation.issue_number_string  = issue_number_string.to_s  unless issue_number_string.nil?
      manifestation.isbn                 = isbn.to_s                 unless isbn.nil?
      manifestation.issn                 = issn.to_s                 unless issn.nil?
      manifestation.lccn                 = lccn.to_s                 unless lccn.nil?
      manifestation.marc_number          = marc_number.to_s          unless marc_number.nil?
      manifestation.ndc                  = ndc.to_s                  unless ndc.nil?
      manifestation.height               = height                    unless height.nil?
      manifestation.width                = width                     unless width.nil?
      manifestation.depth                = depth                     unless depth.nil?
      manifestation.price                = price                     unless price.nil?
      manifestation.access_address       = access_address.to_s       unless access_address.nil?
      manifestation.acceptance_number    = acceptance_number         unless acceptance_number.nil?
      manifestation.repository_content   = repository_content        unless repository_content.nil?
      manifestation.required_role        = required_role             unless required_role.nil?
      manifestation.except_recent        = except_recent             unless except_recent.nil?
      manifestation.description          = description.to_s          unless description.nil?
      manifestation.supplement           = supplement.to_s           unless supplement.nil?
      manifestation.note                 = note.to_s                 unless note.blank?
      manifestation.during_import        = true
      unless start_page.nil?
        if start_page.to_s.blank?
          manifestation.start_page = nil
        else
          manifestation.start_page = start_page.to_s
        end
      end
      unless end_page.nil?
        if end_page.to_s.blank?
          manifestation.end_page = nil
        else
          manifestation.end_page = end_page.to_s
        end
      end
      unless missing_issue.nil?
        if missing_issue.blank?
          manifestation.missing_issue = nil
        else
          manifestation.missing_issue = missing_issue.to_i
        end
      end
      manifestation.save!

      # creator
      creators_string = datas[@field[I18n.t('resource_import_textfile.excel.book.creator')]]
      creators        = creators_string.nil? ? nil : creators_string.to_s.split(';')
      unless creators.nil?
        creators_list   = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
        creator_patrons = Patron.import_patrons(creators_list)
        manifestation.creators = creator_patrons
      end
      # publisher
      publishers_string = datas[@field[I18n.t('resource_import_textfile.excel.book.publisher')]]
      publishers        = publishers_string.nil? ? nil : publishers_string.to_s.split(';')
      unless publishers.nil?
        publishers_list   = publishers.inject([]){ |list, publisher| list << {:full_name => publisher.to_s.strip, :full_name_transcription => "" } }
        publisher_patrons = Patron.import_patrons(publishers_list)
        manifestation.publishers = publisher_patrons
      end
      # contributor
      contributors_string = datas[@field[I18n.t('resource_import_textfile.excel.book.contributor')]]
      contributors        = contributors_string.nil? ? nil : contributors_string.to_s.split(';')
      unless contributors.nil?
        contributors_list   = contributors.inject([]){ |list, contributor| list << {:full_name => contributor.to_s.strip, :full_name_transcription => "" } }
        contributor_patrons = Patron.import_patrons(contributors_list)
        manifestation.contributors = contributor_patrons
      end
      # subject
      subjects_list_string = datas[@field[I18n.t('resource_import_textfile.excel.article.subject')]]
      subjects_list        = subjects_list_string.nil? ? nil : subjects_list_string.to_s.split(';')
      unless subjects_list.nil?
        subjects = Subject.import_subjects (subjects_list)
        manifestation.subjects = subjects
      end

      return manifestation
    end

    def exist_same_book?(datas, manifestation, series_statement = nil)
      original_title    = datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]]
      pub_date          = datas[@field[I18n.t('resource_import_textfile.excel.book.pub_date')]]
      creators_string   = datas[@field[I18n.t('resource_import_textfile.excel.book.creator')]]
      creators          = creators_string.nil? ? nil : creators_string.to_s.split(';')
      publishers_string = datas[@field[I18n.t('resource_import_textfile.excel.book.publisher')]]
      publishers        = publishers_string.nil? ? nil : publishers_string.to_s.split(';')
      series_title      = series_statement.original_title if @manifestation_type.is_series?
      if manifestation
        original_title = manifestation.original_title.to_s                if original_title.nil?
        pub_date       = manifestation.pub_date.to_s                      if pub_date.nil?
        creators       = manifestation.creators.map{ |c| c.full_name }    if creators.nil?
        publishers     = manifestation.publishers.map{ |p| p.full_name }  if publishers.nil?
      end
      return manifestation if original_title.nil? or original_title.blank?
      return manifestation if pub_date.nil? or pub_date.blank?
      return manifestation if creators.size == 0
      return manifestation if publishers.size ==0

      conditions = []
      conditions << "(manifestations).original_title = \'#{original_title.to_s.gsub("'","''")}\'" 
      conditions << "(manifestations).pub_date = \'#{pub_date.to_s.gsub("'", "''")}\'"
      conditions << "(series_statements).original_title = \'#{series_title.to_s.gsub("'", "''")}\'" unless @manifestation_type.is_series?
      conditions << "creates.id is not null"
      conditions << "produces.id is not null"
      conditions = conditions.join(' and ')
      book = nil
=begin
      if @manifestation_type.is_series?
        book = Manifestation.find(
          :first,
          :readonly => false,
          :joins => :series_statement,
          :include => [:creators, :publishers],
          :conditions =>
            "(manifestations).original_title = \'#{original_title}\'
              and (manifestations).pub_date = \'#{pub_date}\'
              and (series_statements).original_title = \'#{series_title}\'
              and creates.id is not null
              and produces.id is not null"
        )
      else
        book = Manifestation.find(
          :first,
          :include => [:creators, :publishers],
          :conditions => 
            "original_title = \'#{original_title}\'
              and pub_date = \'#{pub_date}\' 
              and creates.id is not null 
              and produces.id is not null"
        )
      end
=end
      book = Manifestation.find(
        :first,
        :readonly => false,
        :include => [:series_statement, :creators, :publishers],
        :conditions => conditions
      )
      if book
        if book.creators.map{ |c| c.full_name }.sort == creators.sort and book.publishers.map{ |s| s.full_name }.sort == publishers.sort
          @mode = 'edit'
          return book
        end
      end
      return manifestation
    end

    def import_isbn(isbn)
      manifestation = nil

      unless isbn.blank?
        begin
          isbn = Lisbn.new(isbn)
          manifestation = Manifestation.find_by_isbn(isbn)
          if manifestation
            @mode = "edit"
          else
            manifestation = Manifestation.import_isbn(isbn)
          end
          raise I18n.t('resource_import_textfile.error.book.wrong_isbn') unless manifestation
        rescue EnjuNdl::InvalidIsbn
          raise I18n.t('resource_import_textfile.error.book.wrong_isbn')
        rescue EnjuNdl::RecordNotFound
          raise I18n.t('resource_import_textfile.error.book.wrong_isbn')
        end
      end
      return manifestation
    end

    def import_series_statement(datas, manifestation)
      series_statement = nil
      series_statement = manifestation.series_statement if manifestation and manifestation.series_statement

      issn = datas[@field[I18n.t('resource_import_textfile.excel.series.issn')]]
      if issn
        begin
          issn = Lisbn.new(issn.to_s)
        rescue
          raise I18n.t('resource_import_textfile.error.series.wrong_issn')
        end
      end
      series_statement = SeriesStatement.where(:issn => issn).first unless series_statement

      original_title      = datas[@field[I18n.t('resource_import_textfile.excel.series.original_title')]]
      title_transcription = datas[@field[I18n.t('resource_import_textfile.excel.series.title_transcription')]]
      periodical          = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.series.periodical')]])
      series_identifier   = datas[@field[I18n.t('resource_import_textfile.excel.series.series_statement_identifier')]]
      unless series_statement.nil?
        original_title      = series_statement.original_title              if original_title.nil?
        title_transcription = series_statement.title_transcription         if title_transcription.nil?
        periodical          = series_statement.periodical                  if periodical.nil?
        series_identifier   = series_statement.series_statement_identifier if series_identifier.nil?
        issn                = series_statement.issn                        if issn.nil?
      end
      series_statement = SeriesStatement.where(:original_title => original_title.to_s).first
      series_statement = SeriesStatement.new unless series_statement

      series_statement.original_title              = original_title.to_s      unless original_title.nil?
      series_statement.title_transcription         = title_transcription.to_s unless title_transcription.nil?
      series_statement.periodical                  = periodical               unless periodical.nil?
      series_statement.series_statement_identifier = series_identifier.to_s   unless series_identifier.nil?
      series_statement.issn                        = issn.to_s                unless issn.nil?
      series_statement.save! 
      return series_statement
    end

    def create_book_item(datas, manifestation, item)
      begin
        resource_import_textfile = ResourceImportTextfile.find(@textfile_id)
        @mode_item = 'edit'
        accept_type         = set_data(datas, AcceptType, 'accept_type', { :can_blank => true, :check_column => :display_name })
        acquired_at         = check_data_is_date(datas[@field[I18n.t('resource_import_textfile.excel.book.acquired_at')]], 'acquired_at')      
        library             = set_library(datas[@field[I18n.t('resource_import_textfile.excel.book.library')]], resource_import_textfile.user)
        shelf               = set_shelf(datas[@field[I18n.t('resource_import_textfile.excel.book.shelf')]], resource_import_textfile.user, library)
        checkout_type       = set_data(datas, CheckoutType, 'checkout_type', { :default => 'book' })
        circulation_status  = set_data(datas, CirculationStatus, 'circulation_status', { :default => 'In Process' })
        retention_period    = set_data(datas, RetentionPeriod, 'retention_period', { :default => '永年', :check_column => :display_name })
        call_number         = datas[@field[I18n.t('resource_import_textfile.excel.book.call_number')]]
        price               = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.item_price')]], 'item_price')
        url                 = datas[@field[I18n.t('resource_import_textfile.excel.book.url')]]
        include_supplements = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.include_supplements')]])
        use_restriction     = fix_use_restriction(datas[@field[I18n.t('resource_import_textfile.excel.book.use_restriction')]])
        note                = datas[@field[I18n.t('resource_import_textfile.excel.book.item_note')]]
        required_role       = set_data(datas, Role, 'required_role', { :default => 'Guest' })
        remove_reason       = set_data(datas, RemoveReason, 'remove_reason', { :can_blank => true, :check_column => :display_name })
        item_identifier     = datas[@field[I18n.t('resource_import_textfile.excel.book.item_identifier')]]
        non_searchable      = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.non_searchable')]])

        unless item
          if manifestation.items.size > 0
            item = manifestation.items.first if item_identifier.nil?
          else
            item = Item.new
            @mode_item = 'create'
          end
        end

        # rank
        rank = fix_rank(datas[@field[I18n.t('resource_import_textfile.excel.book.rank')]], manifestation, {:mode => @mode_item})
        if rank == 0 and item.item_identifier.nil? and item_identifier.nil?#@mode_item == 'create' and rank == 0 and item_identifier.nil?
          item_identifier = Numbering.do_numbering('book')
        end

        item.manifestation_id    = manifestation.id
        item.accept_type         = accept_type          unless accept_type.nil?
        item.acquired_at         = acquired_at          unless acquired_at.nil?
        item.shelf               = shelf                unless shelf.nil?
        item.checkout_type       = checkout_type        unless checkout_type.nil?
        item.circulation_status  = circulation_status   unless circulation_status.nil?
        item.retention_period    = retention_period     unless retention_period.nil?
        item.call_number         = call_number.to_s     unless call_number.nil?
        item.price               = price                unless price.nil?
        item.url                 = url.to_s             unless url.nil?
        item.include_supplements = include_supplements  unless include_supplements.nil?
        item.use_restriction_id  = use_restriction.id   unless use_restriction.nil?
        item.note                = note.to_s            unless note.nil?
        item.required_role       = required_role        unless required_role.nil?
        item.item_identifier     = item_identifier.to_s unless item_identifier.nil?
        item.non_searchable      = non_searchable       unless non_searchable.nil?
        item.remove_reason       = remove_reason        unless remove_reason.nil?
        item.rank                = rank                 unless rank.nil?

        # bookstore
        bookstore_name = datas[@field[I18n.t('resource_import_textfile.excel.book.bookstore')]]
        bookstore = Bookstore.import_bookstore(bookstore_name) rescue nil unless bookstore_name == ""
        unless bookstore.nil?
          item.bookstore = bookstore == "" ? nil : bookstore
        end
        # if removed?
        unless item.remove_reason.nil?
          item.circulation_status = CirculationStatus.where(:name => "Removed").first
          item.removed_at = Time.zone.now
        end

        item.save!
        item.patrons << shelf.library.patron if @mode_item == 'create'
        item.manifestation = manifestation
        unless item.remove_reason.nil?
          if item.reserve
            item.reserve.revert_request rescue nil
          end
        end
        return item
      rescue Exception => e
        p "error at fetch_new: #{e.message}"
        raise e
      end
    end

    def has_necessary_cell?(datas, sheet, row, textresult)
      require_cell_book   = [datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]],
                             datas[@field[I18n.t('resource_import_textfile.excel.book.isbn')]]]
      require_cell_series = [datas[@field[I18n.t('resource_import_textfile.excel.series.original_title')]],
                             datas[@field[I18n.t('resource_import_textfile.excel.series.issn')]]]
      if datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]] == ''
        textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}] #{I18n.t('resource_import_textfile.error.book.not_delete')}"
        textresult.save
        return false
      end
      if @manifestation_type.is_book?  
        if require_cell_book.reject{ |f| f.to_s.strip == "" }.empty?
          textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}] #{I18n.t('resource_import_textfile.error.book.cell_is_blank')}"
          textresult.save
          return false
        end
      else
        if require_cell_series.reject{ |f| f.to_s.strip == "" }.empty? or require_cell_book.reject{ |f| f.to_s.strip == "" }.empty?
          textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}] #{I18n.t('resource_import_textfile.error.series.cell_is_blank')}"
          textresult.save
          return false
        end 
      end
      return true
    end

    def fix_use_restriction(cell, options = {:mode => 'input'})
      if cell.nil? or cell.blank? or cell.upcase == 'FALSE' or cell == ''
        if options[:mode] == 'input'
          return UseRestriction.where(:name => 'Limited Circulation, Normal Loan Period').first
        else
          return nil
        end
      end
      return UseRestriction.where(:name => 'Not For Loan').first
    end

    def fix_rank(cell, manifestation, options = {:mode => 'create'})
      case cell
      when I18n.t('item.original')
        #if manifestation.items.map{ |i| i.rank.to_i }.compact.include?(0)
        #  raise I18n.t('resource_import_textfile.error.book.has_original', :data => cell)
        #else
        return 0
        #end
      when I18n.t('item.copy')
        return 1
      when I18n.t('item.spare')
        return 2
      when nil, ""
        if options[:mode] == 'create'
          if manifestation.items.size > 0
            if manifestation.items.map{ |i| i.rank.to_i }.compact.include?(0)
              return 1
            end
          end
          return 0
        else
          return nil
        end
      else
        raise I18n.t('resource_import_textfile.error.book.wrong_rank', :data => cell) 
      end
    end

    def set_data(datas, model, field_name, options)
      obj = nil
      options[:can_blank]    = false    if options[:can_blank].nil?
      options[:check_column] = :name    if options[:check_column].nil?

      cell = datas[@field[I18n.t("resource_import_textfile.excel.book.#{field_name}")]]
      if cell.nil?
        unless options[:can_blank]#@mode =='create' and can_blank
          obj = model.where(options[:check_column] => options[:default]).first 
        else
          obj = nil
        end
      elsif options[:can_blank] == true and cell.blank?
        obj = nil
      else
        #obj = options[:model].where(options[:check_column] => cell).first# rescue nil
        obj = model.where(options[:check_column] => cell).first# rescue nil
        if obj.nil?
          raise I18n.t('resource_import_textfile.error.wrong_data',
             :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
        end
      end
      return obj
    end

    def check_data_is_integer(cell, field_name)
      return nil unless cell
      cell = cell.to_s.strip
      if cell.match(/^\d*$/)
        return cell
      elsif cell.match(/^[0-9]+\.0$/)
        return cell.to_i
      elsif cell.match(/\D/)
        raise I18n.t('resource_import_textfile.error.book.only_integer',
          :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
      end
    end

    def check_data_is_numeric(cell, field_name)
      return nil unless cell
      cell = cell.to_s.strip
      if cell.match(/^\d*$/)
        return cell
      elsif cell.match(/^[0-9]+\.0$/)
        return cell.to_i
      elsif cell.match(/^[0-9]*\.[0-9]*$/)
        return cell
      else
        raise I18n.t('resource_import_textfile.error.book.only_numeric',
          :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
      end
    end

    def check_data_is_date(cell, field_name)
      return nil unless cell
      cell = cell.to_s.strip
      unless cell.blank?
        time = Time.zone.parse(cell) rescue nil
        if time.nil?
          raise I18n.t('resource_import_textfile.error.book.only_date',
            :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
        end
      end
      return time
    end

    def set_library(input_library, user, options = {:mode => 'input'})
      if input_library.nil?
        if options[:mode] == 'input'
          return user.library
        else
          return nil
        end  
      else
        library = Library.where(:display_name => input_library.to_s).first rescue nil
        if library.nil?
          raise I18n.t('resource_import_textfile.error.book.not_exsit_library', :library => input_library)
        else
          return library
        end
      end
    end

    def set_shelf(input_shelf, user, library, options = {:mode => 'input'})
      if input_shelf.nil?
        if options[:mode] == 'input' 
          return user.library.in_process_shelf
        else
          return nil
        end
      else
        shelf = Shelf.where(:display_name => input_shelf, :library_id => user.library.id).first rescue nil
        if shelf.nil?
          raise I18n.t('resource_import_textfile.error.book.not_exsit_shelf', :shelf => input_shelf)
        elsif !library.shelves.include?(shelf) 
          raise I18n.t('resource_import_textfile.error.book.has_not_shelf', :data => cell)
        else
          return shelf
        end
      end
    end

    def set_missing_issue(missing_issue, options = {:mode => 'create'})
      return nil if missing_issue.nil?
      missing_issue = missing_issue.to_s.strip
      if missing_issue == I18n.t('missing_issue.no_request')
        return 1
      elsif missing_issue == I18n.t('missing_issue.requested')
        return 2
      elsif missing_issue == I18n.t('missing_issue.received')
        return 3
      elsif missing_issue.blank?
        return options[:mode] == 'delete' ? nil : ""
      else
        raise I18n.t('resource_import_textfile.error.book.wrong_missing_issue', :data => missing_issue)
      end
    end

    def delete_data(datas) 
      ActiveRecord::Base.transaction do
        begin
          item = Item.find(
            :first,
            :readonly => false,
            :include => [
              :manifestation => [:series_statement, :creators, :publishers, :contributors, :subjects],
              :item_has_use_restriction => [:use_restriction],
              :shelf => [:library]
            ],
            :conditions => set_conditions(datas),
            :order => "items.created_at"
          )
          raise I18n.t('resource_import_textfile.error.failed_delete_not_find') unless item
p "@@@@@@"
p set_conditions(datas)
p "@@@@@@"
          creators_string     = datas[@field[I18n.t('resource_import_textfile.excel.book.creator')]]
          creators            = creators_string.nil? ? [] : creators_string.to_s.split(';')
          publishers_string   = datas[@field[I18n.t('resource_import_textfile.excel.book.publisher')]]
          publishers          = publishers_string.nil? ? [] : publishers_string.to_s.split(';')
          contributors_string = datas[@field[I18n.t('resource_import_textfile.excel.book.contributors')]]
          contributors        = contributors_string.nil? ? [] : contributors_string.to_s.split(';')
          subjects_string     = datas[@field[I18n.t('resource_import_textfile.excel.book.subjects')]]
          subjects            = subjects_string.nil? ? [] : subjects_string.to_s.split(';')
          raise I18n.t('resource_import_textfile.error.failed_delete_not_find') unless item.manifestation.creators.map{ |c| c.full_name }.sort == creators.sort
          raise I18n.t('resource_import_textfile.error.failed_delete_not_find') unless item.manifestation.publishers.map{ |p| c.full_name }.sort == publishers.sort
          raise I18n.t('resource_import_textfile.error.failed_delete_not_find') unless item.manifestation.contributors.map{ |c| c.full_name }.sort == contributors.sort
          raise I18n.t('resource_import_textfile.error.failed_delete_not_find') unless item.manifestation.subjects.map{ |s| c.full_name }.sort == subjects.sort

          if item.reserve
            item.reserve.revert_request rescue nil
          end

          manifestation = item.manifestation
          item.delete
          manifestation.delete if manifestation.items.size == 0 
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def set_conditions(datas)
      import_textfile = ResourceImportTextfile.find(@textfile_id)
      # series_statements
      #series_issn         = datas[@field[I18n.t('resource_import_textfile.excel.series.issn')]]
      series_title         = datas[@field[I18n.t('resource_import_textfile.excel.series.original_title')]]
      series_transcription = datas[@field[I18n.t('resource_import_textfile.excel.series.title_transcription')]]
      series_periodical    = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.series.periodical')]])
      series_identifier    = datas[@field[I18n.t('resource_import_textfile.excel.series.series_statement_identifier')]]
      # manifestation
      original_title       = datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]]
      title_transcription  = datas[@field[I18n.t('resource_import_textfile.excel.book.title_transcription')]]
      title_alternative    = datas[@field[I18n.t('resource_import_textfile.excel.book.title_alternative')]]
      pub_date             = datas[@field[I18n.t('resource_import_textfile.excel.book.pub_date')]]
      place_of_publication = datas[@field[I18n.t('resource_import_textfile.excel.book.place_of_publication')]]
      edition              = datas[@field[I18n.t('resource_import_textfile.excel.book.edition_display_value')]]
      volume_number_string = datas[@field[I18n.t('resource_import_textfile.excel.book.volume_number_string')]]
      issue_number_string  = datas[@field[I18n.t('resource_import_textfile.excel.book.issue_number_string')]]
      isbn                 = datas[@field[I18n.t('resource_import_textfile.excel.book.isbn')]]
      issn                 = datas[@field[I18n.t('resource_import_textfile.excel.series.issn')]]
      lccn                 = datas[@field[I18n.t('resource_import_textfile.excel.book.lccn')]]
      marc_number          = datas[@field[I18n.t('resource_import_textfile.excel.book.marc_number')]]
      ndc                  = datas[@field[I18n.t('resource_import_textfile.excel.book.ndc')]]
      start_page           = datas[@field[I18n.t('resource_import_textfile.excel.book.start_page')]]
      end_page             = datas[@field[I18n.t('resource_import_textfile.excel.book.end_page')]]
      height               = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.height')]], 'height')
      width                = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.width')]], 'width') 
      depth                = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.depth')]], 'depth')
      price                = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.price')]], 'price')
      access_address       = datas[@field[I18n.t('resource_import_textfile.excel.book.access_address')]]
      acceptance_number    = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.acceptance_number')]], 'acceptance_number')
      repository_content   = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.repository_content')]])
      except_recent        = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.except_recent')]])
      description          = datas[@field[I18n.t('resource_import_textfile.excel.book.description')]]
      supplement           = datas[@field[I18n.t('resource_import_textfile.excel.book.supplement')]]
      note                 = datas[@field[I18n.t('resource_import_textfile.excel.book.note')]]
      carrier_type         = set_data(datas, CarrierType, 'carrier_type', { :default => 'print', :can_blank => true })
      frequency            = set_data(datas, Frequency, 'frequency', { :default => '不明', :check_column => :display_name, :can_blank => true })
      language             = set_data(datas, Language, 'language', { :default => 'Japanese', :can_blank => true })
      required_role        = set_data(datas, Role, 'required_role', { :default => 'Guest', :can_blank => true })
      missing_issue        = set_missing_issue(datas[@field[I18n.t('resource_import_textfile.excel.book.missing_issue')]], {:mode => 'delete'})
      # item
      acquired_at          = check_data_is_date(datas[@field[I18n.t('resource_import_textfile.excel.book.acquired_at')]], 'acquired_at')      
      call_number          = datas[@field[I18n.t('resource_import_textfile.excel.book.call_number')]]
      item_price           = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.item_price')]], 'item_price')
      url                  = datas[@field[I18n.t('resource_import_textfile.excel.book.url')]]
      include_supplements  = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.include_supplements')]])
      use_restriction      = fix_use_restriction(datas[@field[I18n.t('resource_import_textfile.excel.book.use_restriction')]])
      item_note            = datas[@field[I18n.t('resource_import_textfile.excel.book.item_note')]]
      item_identifier      = datas[@field[I18n.t('resource_import_textfile.excel.book.item_identifier')]]
      non_searchable       = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.non_searchable')]])
      accept_type          = set_data(datas, AcceptType, 'accept_type', { :can_blank => true, :check_column => :display_name, :can_blank => true })
      library              = set_library(datas[@field[I18n.t('resource_import_textfile.excel.book.shelf')]], import_textfile.user, {:mode => 'delete'})
      shelf                = set_shelf(datas[@field[I18n.t('resource_import_textfile.excel.book.shelf')]], import_textfile.user, library, {:mode => 'delete'})
      checkout_type        = set_data(datas, CheckoutType, 'checkout_type', { :default => 'book', :can_blank => true })
      circulation_status   = set_data(datas, CirculationStatus, 'circulation_status', { :default => 'In Process', :can_blank => true })
      retention_period     = set_data(datas, RetentionPeriod, 'retention_period', { :default => '永年', :check_column => :display_name, :can_blank => true })
      item_required_role   = set_data(datas, Role, 'required_role', { :default => 'Guest', :can_blank => true })
      remove_reason        = set_data(datas, RemoveReason, 'remove_reason', { :can_blank => true, :check_column => :display_name, :can_blank => true })
      rank                 = fix_rank(datas[@field[I18n.t('resource_import_textfile.excel.book.rank')]], manifestation, {:mode => 'delete'})

      conditions = []
      # series_statements
      conditions << "(series_statements).original_title = \'#{series_title.gsub("'", "''")}\'"                   unless series_title.nil?
      conditions << "(series_statements).title_transcription = \'#{series_transcription.gsub("'", "''")}\'"      unless series_transcription.nil? 
      conditions << "(series_statements).periodical = \'#{periodical}\'"                                         unless series_periodical.nil?
      conditions << "(series_statements).series_statement_identifier = \'#{series_identifier.gsub("'", "''")}\'" unless series_identifier.nil?
      # manifestation
      conditions << "(manifestations).original_title = \'#{original_title.gsub("'", "''")}\'"                    unless original_title.nil?
      conditions << "(manifestations).title_transcription = \'#{title_transcription.gsub("'", "''")}\'"          unless title_transcription.nil?
      conditions << "(manifestations).title_alternative = \'#{title_alternative.gsub("'", "''")}\'"              unless title_alternative.nil?
      conditions << "(manifestations).carrier_type_id = #{carrier_type.id.to_i}"                                 unless carrier_type.nil?
      conditions << "(manifestations).frequency_id = #{frequency.id}"                                            unless frequency.nil?
      conditions << "(manifestations).pub_date = \'#{pub_date.gsub("'", "''")}\'"                                unless pub_date.nil?
      conditions << "(manifestations).place_of_publication = \'#{place_of_publication.gsub("'", "''")}\'"        unless place_of_publication.nil?
      conditions << "(manifestations).language_id = \'#{language.id}\'"                                          unless language.nil?
      conditions << "(manifestations).edition_display_value = \'#{edition.gsub("'", "''")}\'"                    unless edition.nil?
      conditions << "(manifestations).volume_number_string = \'#{volume_number_string.gsub("'", "''")}\'"        unless volume_number_string.nil?
      conditions << "(manifestations).issue_number_string = \'#{issue_number_string.gsub("'", "''")}\'"          unless issue_number_string.nil?
      conditions << "(manifestations).issn = \'#{isbn.gsub("'", "''")}\'"                                        unless isbn.nil?
      conditions << "(manifestations).issn = \'#{issn.gsub("'", "''")}\'"                                        unless issn.nil?
      conditions << "(manifestations).lccn = \'#{lccn.gsub("'", "''")}\'"                                        unless lccn.nil?
      conditions << "(manifestations).marc_number = \'#{marc_number.gsub("'", "''")}\'"                          unless marc_number.nil?
      conditions << "(manifestations).ndc = \'#{ndc.gsub("'", "''")}\'"                                          unless ndc.nil?
      conditions << "(manifestations).start_page = \'#{start_page.gsub("'", "''")}\'"                            unless start_page.nil?
      conditions << "(manifestations).end_page = \'#{end_page.gsub("'", "''")}\'"                                unless end_page.nil?
      conditions << "(manifestations).height = #{height}"                                                        unless height.nil?
      conditions << "(manifestations).width = #{width}"                                                          unless width.nil?
      conditions << "(manifestations).depth = #{depth}"                                                          unless depth.nil?
      conditions << "(manifestations).price = #{price}"                                                          unless price.nil?
      conditions << "(manifestations).access_address = \'#{access_address}\'"                                    unless access_address.nil?
      conditions << "(manifestations).acceptance_number = \'#{acceptance_number}\'"                              unless acceptance_number.nil?
      conditions << "(manifestations).repository_content = \'#{repository_content}\'"                            unless repository_content.nil?
      conditions << "(manifestations).required_role_id = #{required_role.id}"                                    unless required_role.nil?
      conditions << "(manifestations).except_recent = \'#{except_recent}\'"                                      unless except_recent.nil?
      conditions << "(manifestations).description = \'#{description.gsub("'", "''")}\'"                          unless description.nil?
      conditions << "(manifestations).supplement = \'#{supplement.gsub("'", "''")}\'"                            unless supplement.nil?
      conditions << "(manifestations).note = \'#{note.gsub("'", "''")}\'"                                        unless note.nil?
      conditions << "(manifestations).missing_issue = #{missing_issue}"                                          unless missing_issue.nil?
      # item
      conditions << "(items).acquired_at = \'#{acquired_at}\'"                                                   unless acquired_at.nil?
      conditions << "(items).call_number = \'#{call_number.gsub("'", "''")}\'"                                   unless call_number.nil?
      conditions << "(items).price = \'#{item_price}\     '"                                                     unless item_price.nil?
      conditions << "(items).url = \'#{url.gsub("'", "''")}\'"                                                   unless url.nil?
      conditions << "(items).include_supplements = \'#{include_supplements}\'"                                   unless include_supplements.nil?
      conditions << "(items).note = \'#{item_note.gsub("'", "''")}\'"                                            unless item_note.nil?
      conditions << "(items).item_identifier = \'#{item_identifier}\'"                                           unless item_identifier.nil?
      conditions << "(items).accept_type_id = #{accept_type.id}"                                                 unless accept_type.nil?
      conditions << "(items).checkout_type_id = #{checkout_type.id}"                                             unless checkout_type.nil?
      conditions << "(items).circulation_status_id = #{circulation_status.id}"                                   unless circulation_status.nil?
      conditions << "(items).retention_period_id = #{retention_period.id}"                                       unless retention_period.nil?
      conditions << "(items).required_role_id = #{item_required_role.id}"                                        unless item_required_role.nil?
      conditions << "(items).remove_reason_id = #{remove_reason.id}"                                             unless remove_reason.nil?
      conditions << "(items).non_searchable = \'#{non_searchable}\'"                                             unless non_searchable.nil?
      conditions << "(items).rank = #{rank}"                                                                     unless rank.nil?
      conditions << "(libraries).id = #{library.id}"                                                             unless library.nil?
      conditions << "(shelves).id = #{shelf.id}"                                                                 unless shelf.nil?
      conditions << "(use_restrictions).id = #{use_restriction.id}"                                              unless use_restriction.nil?
      return conditions.join(' and ')
    end
  end
end

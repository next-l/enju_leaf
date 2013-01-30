# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportBook
    def import_book(filename, id, extraparams)
      @manifestation_type = ManifestationType.find(extraparams['manifestation_type'].to_i)
      @textfile_id = id
      @oo = Excelx.new(filename)

      extraparams["sheet"].each_with_index do |sheet, i|
        logger.info "num=#{i}  sheet=#{sheet}"
        @oo.default_sheet = sheet
        set_book_field(sheet)
        import_book_data(sheet)
      end
    end 

    def set_book_field(sheet)
      field_row_num = 1
      has_error = false

      # read the field, then set field a hash
      @field = Hash::new
      @oo.first_column.upto(@oo.last_column) do |column|
        @field.store(@oo.cell(field_row_num, column).to_s, column)
      end
      import_textresult = ResourceImportTextresult.new(:resource_import_textfile_id => @textfile_id, :extraparams => "{'sheet'=>'#{sheet}'}" )
      require_book = [@field[I18n.t('resource_import_textfile.excel.book.original_title')],
                      @field[I18n.t('resource_import_textfile.excel.book.isbn')]]
      require_series = [@field[I18n.t('resource_import_textfile.excel.series.original_title')],
                        @field[I18n.t('resource_import_textfile.excel.series.issn')]]
      if @manifestation_type.is_book?
        if require_book.reject{ |field| field.to_s.strip == "" }.empty?
          import_textresult.error_msg = I18n.t('resource_import_textfile.error.book.head_is_blank', :sheet => sheet)
          has_error = true
        else
          import_textresult.body      = @field.keys.join("\t")
          import_textresult.error_msg = I18n.t('resource_import_textfile.message.read_sheet', :sheet => sheet)
        end
      else
        if require_series.reject{ |f| f.to_s.strip == "" }.empty? or require_book.reject{ |f| f.to_s.strip == "" }.empty?
          import_textresult.error_msg = I18n.t('resource_import_textfile.error.series.head_is_blank', :sheet => sheet)
          has_error = true
        else
          import_textresult.body      = @field.keys.join("\t")
          import_textresult.error_msg = I18n.t('resource_import_textfile.message.read_sheet', :sheet => sheet)
        end
      end
      import_textresult.save
      raise if has_error
    end

    def import_book_data(sheet)
      first_data_row_num = 2
      num = { :manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0 }

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
          manifestation = fetch_book(datas)
          num[:manifestation_imported] += 1 if manifestation
          import_textresult.manifestation = manifestation
          if manifestation.valid?
            resource_import_textfile = ResourceImportTextfile.find(@textfile_id)
            import_textresult.item = create_book_item(datas, manifestation, resource_import_textfile)
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
          import_textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}]: #{e.message}"
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

    def fetch_book(datas)
      @mode = 'create'
      manifestation = nil

      isbn = datas[@field[I18n.t('resource_import_textfile.excel.book.isbn')]].to_s
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
      unless  manifestation
        manifestation = exist_same_book?(datas)
        unless manifestation
          manifestation = Manifestation.new
        end
      end

      ResourceImportTextfile.transaction do
        begin
          original_title       = datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]].to_s 
          title_transcription  = datas[@field[I18n.t('resource_import_textfile.excel.book.title_transcription')]].to_s
          title_alternative    = datas[@field[I18n.t('resource_import_textfile.excel.book.title_alternative')]].to_s
          carrier_type         = set_data(CarrierType, datas[@field[I18n.t('resource_import_textfile.excel.book.carrier_type')]], false, 'carrier_type', 'print')
          frequency            = set_data(Frequency, datas[@field[I18n.t('resource_import_textfile.excel.book.frequency')]], false, 'frequency', '不明', :display_name)
          pub_date             = datas[@field[I18n.t('resource_import_textfile.excel.book.pub_date')]].to_s
          place_of_publication = datas[@field[I18n.t('resource_import_textfile.excel.book.place_of_publication')]].to_s
          language             = set_data(Language, datas[@field[I18n.t('resource_import_textfile.excel.book.language')]], false, 'language', 'Japanese')
          edition              = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.edition')]].to_s, 'edition')
          volume_number_string = datas[@field[I18n.t('resource_import_textfile.excel.book.volume_number_string')]].to_s
          issue_number_string  = datas[@field[I18n.t('resource_import_textfile.excel.book.issue_number_string')]].to_s
          lccn                 = datas[@field[I18n.t('resource_import_textfile.excel.book.lccn')]].to_s
          start_page           = datas[@field[I18n.t('resource_import_textfile.excel.book.start_page')]].to_s
          end_page             = datas[@field[I18n.t('resource_import_textfile.excel.book.end_page')]].to_s 
          height               = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.height')]].to_s, 'height')
          width                = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.width')]].to_s, 'width') 
          depth                = check_data_is_numeric(datas[@field[I18n.t('resource_import_textfile.excel.book.depth')]].to_s, 'depth')
          price                = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.price')]].to_s, 'price')
          access_address       = datas[@field[I18n.t('resource_import_textfile.excel.book.access_address')]].to_s
          acceptance_number    = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.acceptance_number')]].to_s, 'acceptance_number')
          repository_content   = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.repository_content')]])
          required_role        = set_data(Role, datas[@field[I18n.t('resource_import_textfile.excel.book.required_role')]], false, 'required_role', 'Guest')
          except_recent        = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.except_recent')]])
          description          = datas[@field[I18n.t('resource_import_textfile.excel.book.description')]].to_s
          supplement           = datas[@field[I18n.t('resource_import_textfile.excel.book.supplement')]].to_s
          note                 = datas[@field[I18n.t('resource_import_textfile.excel.book.note')]].to_s

p @mode
          manifestation.manifestation_type   = @manifestation_type
          manifestation.original_title       = original_title       unless original_title.blank?
          manifestation.title_transcription  = title_transcription  unless title_transcription.blank?
          manifestation.title_alternative    = title_alternative    unless title_alternative.blank?
          manifestation.pub_date             = pub_date             unless pub_date.blank?
          manifestation.place_of_publication = place_of_publication unless place_of_publication.blank?
          manifestation.language             = language             unless language.blank?
          manifestation.edition              = edition              unless edition.blank?
          manifestation.volume_number_string = volume_number_string unless volume_number_string.blank?
          manifestation.issue_number_string  = issue_number_string  unless issue_number_string.blank?
          manifestation.isbn                 = isbn                 unless isbn.blank?
          manifestation.lccn                 = lccn                 unless lccn.blank?
          manifestation.start_page           = start_page           unless start_page.blank?
          manifestation.end_page             = end_page             unless end_page.blank?
          manifestation.height               = height               unless height.blank?
          manifestation.width                = width                unless width.blank?
          manifestation.depth                = depth                unless depth.blank?
          manifestation.price                = price                unless price.blank?
          manifestation.access_address       = access_address       unless access_address.blank?
          manifestation.acceptance_number    = acceptance_number    unless acceptance_number.blank?
          manifestation.required_role        = required_role        unless required_role.blank?
          manifestation.description          = description          unless description.blank?
          manifestation.supplement           = supplement           unless supplement.blank?
          manifestation.note                 = note                 unless note.blank?
          manifestation.during_import        = true
          manifestation.save!

          # creator
          creators        = datas[@field[I18n.t('resource_import_textfile.excel.book.creator')]].split(';')
          unless creators.blank?
            creators_list   = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
            creator_patrons = Patron.import_patrons(creators_list)
            manifestation.creators = creator_patrons
          end
          # publisher
          publishers        = datas[@field[I18n.t('resource_import_textfile.excel.book.publisher')]].split(';')
          unless publishers.blank?
            publishers_list   = publishers.inject([]){ |list, publisher| list << {:full_name => publisher.to_s.strip, :full_name_transcription => "" } }
            publisher_patrons = Patron.import_patrons(publishers_list)
            manifestation.publishers = publisher_patrons
          end
          # contributor
          contributors        = datas[@field[I18n.t('resource_import_textfile.excel.book.contributor')]].split(';')
          unless contributors.blank?
          contributors_list   = contributors.inject([]){ |list, contributor| list << {:full_name => contributor.to_s.strip, :full_name_transcription => "" } }
          contributor_patrons = Patron.import_patrons(contributors_list)
          manifestation.contributors = contributor_patrons
          # subject
          end
          subjects_list = datas[@field[I18n.t('resource_import_textfile.excel.article.subject')]].to_s.split(';')
          unless subjects_list.blank?
            subjects = Subject.import_subjects (subjects_list)
            manifestation.subjects = subjects
          end

          series_statement = import_series_statement(datas)
          manifestation.series_statement = series_statement if series_statement

          return manifestation
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def exist_same_book?(datas, manifestation)
      original_title = datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]].to_s
      pub_date       = datas[@field[I18n.t('resource_import_textfile.excel.book.pub_date')]].to_s
      creators       = datas[@field[I18n.t('resource_import_textfile.excel.book.creator')]].split(';')
      publishers     = datas[@field[I18n.t('resource_import_textfile.excel.book.publisher')]].split(';') 
      series_title   = datas[@field[I18n.t('resource_import_textfile.excel.series.original_title')]].to_s

      book = nil
      if @manifestation_type.is_series?
        book = Manifestation.find(
          :first,
          :joins => :series_statement,
          :include => [:creators, :publishers],
          :conditions =>
            "original_title = \'#{original_title}\'
              and pub_date = \'#{pub_date}\'
              and series_statements.original_title = \'#{series_title}\'
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
      if book
        if book.creators.map{ |c| c.full_name }.sort == creators.sort and book.publishers.map{ |s| s.full_name }.sort == publishers.sort
          @mode = 'edit'
          return book
        end
        return manifestation
      end
    end

    def import_series_statement(datas)
      series_statement = nil
#!!!!!!!!!!!!! シリーズの書誌同定はどうするか
      issn                = datas[@field[I18n.t('resource_import_textfile.excel.series.issn')]].to_s
      original_title      = datas[@field[I18n.t('resource_import_textfile.excel.series.original_title')]].to_s
      title_transcription = datas[@field[I18n.t('resource_import_textfile.excel.series.title_transcription')]].to_s
      periodical          = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.series.periodical')]])
      series_identifier   = datas[@field[I18n.t('resource_import_textfile.excel.series.series_statement_identifier')]].to_s

      unless issn.blank?
        begin
          issn = Lisbn.new(issn)
          series_statement = SeriesStatement.where(:issn => issn).first
          series_statement = SeriesStatemen.new(:issn => issn) unless series_statement
        rescue
          raise I18n.t('resource_import_textfile.error.series.wrong_issn') 
        end
      end
      series_statement = SeriesStatemen.new unless series_statement
      series_statement.original_title      = original_title      unless original_title.blank?
      series_statement.title_transcription = title_transcription unless title_transcription.blank?
      series_statement.periodical          = periodical          unless periodical.blank?
      series_statement.series_identifier   = series_identifier   unless series_identifier.blank?
      series_statement.save! 
      return series_statement
    end

    def create_book_item(datas, manifestation, resource_import_textfile)
      item = nil
      accept_type         = set_data(AcceptType, datas[@field[I18n.t('resource_import_textfile.excel.book.accept_type')]], true, 'accept_type', '', :display_name)
      acquired_at         = check_data_is_date(datas[@field[I18n.t('resource_import_textfile.excel.book.acquired_at')]], 'acquired_at')      
      shelf               = select_item_shelf(datas[@field[I18n.t('resource_import_textfile.excel.book.shelf')]], resource_import_textfile.user)
      checkout_type       = set_data(CheckoutType, datas[@field[I18n.t('resource_import_textfile.excel.book.checkout_type')]], false, 'checkout_type', 'book')
      circulation_status  = set_data(CirculationStatus, datas[@field[I18n.t('resource_import_textfile.excel.book.circulation_status')]], false, 'circulation_status', 'In Process')
      retention_period    = set_data(RetentionPeriod, datas[@field[I18n.t('resource_import_textfile.excel.book.retention_period')]], false, 'retention_period', '永年', :display_name)
      call_number         = datas[@field[I18n.t('resource_import_textfile.excel.book.call_number')]]
      price               = check_data_is_integer(datas[@field[I18n.t('resource_import_textfile.excel.book.item_price')]], 'item_price')
      url                 = datas[@field[I18n.t('resource_import_textfile.excel.book.url')]]
      include_supplements = fix_boolean(datas[@field[I18n.t('resource_import_textfile.excel.book.include_supplements')]])
      use_restriction     = fix_use_restriction(datas[@field[I18n.t('resource_import_textfile.excel.book.use_restriction')]])
      note                = datas[@field[I18n.t('resource_import_textfile.excel.book.item_note')]]
      rank                = fix_rank(datas[@field[I18n.t('resource_import_textfile.excel.book.rank')]])
      required_role       = set_data(Role, datas[@field[I18n.t('resource_import_textfile.excel.book.required_role')]], false, 'required_role', 'Guest')
      #remove_reason       = set_data(AcceptType, datas[@field[I18n.t('resource_import_textfile.excel.book.remoce_reason')]], true, 'remove_reason', '', :display_name)
      item_identifier     = datas[@field[I18n.t('resource_import_textfile.excel.item_identifier')]]

      @mode_item = 'create'
      if item_identifier.blank?
        if manifestation.items.size > 0
          item = manifestation.items.first
        end
      else
        item = Item.where(:item_identifier => item_identifer).first rescue nil
      end
      if item.nil?
        item = Item.new
      else
        @mode_item = 'edit'
      end
p "mode_i_#{@mode_item}"

      if item_identifier.blank? and rank == 0 and item.item_identifier.nil?
        item_identifier = Numbering.do_numbering('book')
      end

      item.accept_type         = accept_type         unless accept_type.blank?
      item.acquired_at         = acquired_at         unless acquired_at.blank?
      item.shelf               = shelf               unless shelf.blank?
      item.checkout_type       = checkout_type       unless checkout_type.blank?
      item.circulation_status  = circulation_status  unless circulation_status.blank?
      item.call_number         = call_number         unless call_number.blank?
      item.price               = price               unless price.blank?
      item.url                 = url                 unless url.blank?
      item.include_supplements = include_supplements unless include_supplements.blank?
      item.use_restriction     = use_restriction     unless use_restriction.blank?
      item.note                = note                unless note.blank?
      item.rank                = rank                unless rank.blank?
      item.required_role       = required_role       unless required_role.blank?
      item.item_identifier     = item_identifier     unless item_identifier.blank?  

      item.save!
      item.patrons << shelf.library.patron if @mode_item == 'create'

=begin
      unless item.remove_reason.nil?
        if item.reserve
          item.reserve.revert_request rescue nil
        end
      end
=end
      return item
    end

    def has_necessary_cell?(datas, sheet, row, textresult)
      require_cell_book   = [datas[@field[I18n.t('resource_import_textfile.excel.book.original_title')]],
                             datas[@field[I18n.t('resource_import_textfile.excel.book.isbn')]]]
      require_cell_series = [datas[@field[I18n.t('resource_import_textfile.excel.series.original_title')]],
                             datas[@field[I18n.t('resource_import_textfile.excel.series.issn')]]]
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
      true
    end

    def fix_use_restriction(cell)
      unless cell.size == 0 or cell.upcase == 'FALSE'
        return UseRestriction.where(:name => 'Not For Loan').first
      end
      return UseRestriction.where(:name => 'Limited Circulation, Normal Loan Period').first
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

    def set_data(model, cell, can_blank, field_name, default, check_column = :name)
      if cell.blank?
        unless @mode =='create' and can_blank
          obj = model.where(check_column => default).first 
        else
          obj = nil
        end
      else
        obj = model.where(check_column => cell).first rescue nil
        if obj.nil?
          raise I18n.t('resource_import_textfile.error.book.wrong_data',
             :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
        end
      end
      return obj
    end

    def check_data_is_integer(cell, field_name)
      cell = cell.to_s
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
      cell = cell.to_s
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
      time = Time.zone.parse(cell) rescue nil
      unless cell.blank?
        if time.nil?
          raise I18n.t('resource_import_textfile.error.book.only_integer',
            :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
        end
      end
      return time
    end

    def select_item_shelf(input_shelf, user)
      if input_shelf.blank?
        return user.library.in_process_shelf
      else
        shelf = Shelf.where(:display_name => input_shelf, :library_id => user.library.id).first rescue nil
        if shelf.nil?
          raise I18n.t('resource_import_textfile.error.book.not_exsit_shelf', :shelf => input_shelf)
        else
          return shelf
        end
      end
    end
  end
end

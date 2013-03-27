# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportArticle
    def import_article(sheet, errors)
      error_msg = check_article_header_field(sheet)
      unless error_msg
        import_textresult = ResourceImportTextresult.new(
          :resource_import_textfile_id => @textfile_id,
          :extraparams                 => "{'sheet'=>'#{sheet}'}",
          :body                        => @field.keys.join("\t"),
          :error_msg                   => I18n.t('resource_import_textfile.message.read_sheet', :sheet => sheet),
          :failed                      => true
        )
        import_textresult.save!
        import_article_data(sheet)
      else
        errors << { :msg => error_msg, :sheet => sheet }
      end
      return errors
    end 

    def check_article_header_field(sheet)
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

      # check that exist need fields
      require_field = [@field[I18n.t('resource_import_textfile.excel.article.original_title')]]
      if require_field.reject{|field| field.to_s.strip == ""}.empty?
        return I18n.t('resource_import_textfile.error.article.head_is_blank', :sheet => sheet)
      end
      return nil
    end

    def import_article_data(sheet)
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
          :body                        => datas.values.join("\t"),
          :extraparams                 => "{'sheet'=>'#{sheet}'}"
        )

        begin
          ActiveRecord::Base.transaction do
            # check cell
            require_cell = [datas[@field[I18n.t('resource_import_textfile.excel.article.original_title')]]]
            if require_cell.reject{ |field| field.to_s.strip == "" }.empty?
              raise I18n.t('resource_import_textfile.error.article.cell_is_blank')
            end
            manifestation = fetch_article(datas)
            if manifestation.valid?
              item = create_article_item(datas, manifestation)
              item.manifestation = manifestation
              import_textresult.manifestation = manifestation
              import_textresult.item = item
              manifestation.index
              num[:manifestation_imported] += 1 if import_textresult.manifestation
              num[:item_imported] +=1 if import_textresult.item
              if import_textresult.item.manifestation.next_reserve and import_textresult.item.item_identifier
                current_user = User.where(:username => 'admin').first
                import_textresult.item.retain(current_user) if import_textresult.item.available_for_retain?
                import_textresult.error_msg = I18n.t('resource_import_file.reserved_item',
                  :username => import_textresult.item.reserve.user.username,
                  :user_number => import_textresult.item.reserve.user.user_number)
              end
            else
              import_textresult.failed = true
              num[:failed] += 1
            end
          end
        rescue => e
          import_textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}]: #{e.message}"
          import_textresult.failed = true
          Rails.logger.info("FAIL[sheet:#{sheet} row:#{row}] resource registration failed: column #{row}: #{e.message}")
          Rails.logger.info("FAIL[sheet:#{sheet} row:#{row}] #{$@}")
          num[:failed] += 1
        end
        import_textresult.save!
        if row % 50 == 0
          Sunspot.commit
          GC.start
        end
      end
      Rails.cache.write("manifestation_search_total", Manifestation.search.total)
      return num
    end

    def fetch_article(datas)
      @mode = 'create'
      manifestation = exist_same_article?(datas)

      unless manifestation.nil?
        @mode = 'edit'
      else       
        manifestation = Manifestation.new(
          :carrier_type   => CarrierType.where(:name => 'print').first,
          :language       => Language.where(:name => 'Japanese').first,
          :frequency      => Frequency.where(:name => 'unknown').first,
          :required_role  => Role.find('Guest'),
          :during_import  => true,
        )
      end
      original_title = datas[@field[I18n.t('resource_import_textfile.excel.article.original_title')]]
      article_title  = datas[@field[I18n.t('resource_import_textfile.excel.article.title')]]
      pub_date       = datas[@field[I18n.t('resource_import_textfile.excel.article.pub_date')]]
      access_address = datas[@field[I18n.t('resource_import_textfile.excel.article.url')]]

      start_page, end_page        = set_page(datas[@field[I18n.t('resource_import_textfile.excel.article.number_of_page')]])
      volume_number, issue_number = set_number(datas[@field[I18n.t('resource_import_textfile.excel.article.volume_number_string')]])

      manifestation.manifestation_type   = @manifestation_type
      manifestation.original_title       = original_title.to_s unless original_title.nil?
      manifestation.article_title        = article_title.to_s  unless article_title.nil?
      manifestation.pub_date             = pub_date.to_s       unless pub_date.nil?
      manifestation.volume_number_string = volume_number.to_s  unless volume_number.nil?      
      manifestation.issue_number_string  = issue_number.to_s   unless issue_number.nil?
      manifestation.access_address       = access_address.to_s unless access_address.nil?

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
      manifestation.save!
      if @mode == "create"
        p "created manifestation id:#{manifestation.id}"
      else
        p "edited manifestation id:#{manifestation.id}"
      end

      creators_cell   = datas[@field[I18n.t('resource_import_textfile.excel.article.creator')]]
      creators        = set_article_creatos(creators_cell)
      unless creators.nil?
        creators_list   = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
        creator_patrons = Patron.import_patrons(creators_list)
        manifestation.creators = creator_patrons
      end
      subjects_cell = datas[@field[I18n.t('resource_import_textfile.excel.article.subject')]]
      subjects_list = set_article_subjects(subjects_cell)
      unless subjects_list.nil?
        subjects      = Subject.import_subjects (subjects_list)
        manifestation.subjects = subjects
      end
      return manifestation
    end

    def exist_same_article?(datas)
      original_title = datas[@field[I18n.t('resource_import_textfile.excel.article.original_title')]]
      article_title  = datas[@field[I18n.t('resource_import_textfile.excel.article.title')]]
      creators       = set_article_creatos(datas[@field[I18n.t('resource_import_textfile.excel.article.creator')]])
      return nil if original_title.nil? or original_title.blank?
      return nil if article_title.nil? or article_title.blank?
      return nil if creators.nil?

      conditions = []
      conditions << "original_title = \'#{original_title.gsub("'", "''")}\'"
      conditions << "article_title = \'#{article_title.gsub("'", "''")}\'"
      conditions << "creates.id is not null"
      conditions = conditions.join(' and ')

      article =  Manifestation.find(
        :first,
        :include => [:creators],
        :conditions => conditions
      )
      if article
        if article.creators.map{ |c| c.full_name }.sort == creators.sort
          return article
        end
      end
      return nil
    end

    def create_article_item(datas, manifestation)
      @mode_item = 'edit'
      import_textfile = ResourceImportTextfile.find(@textfile_id)
      item = nil
      unless manifestation.items.size > 0
        item = Item.new
        @mode_item = 'create'
      else
        item = manifestation.items.order('created_at asc').first
      end
      shelf = nil
      unless item.shelf.nil?
        unless item.shelf_id == 1
          shelf = item.shelf
        else
          shelf = import_textfile.user.library.article_shelf
        end
      else
        shelf = import_textfile.user.library.article_shelf
      end
      shelf = import_textfile.user.library.article_shelf

      call_number = datas[@field[I18n.t('resource_import_textfile.excel.article.call_number')]]

      item.manifestation_id   = manifestation.id
      item.circulation_status = CirculationStatus.where(:name => 'Not Available').first
      item.use_restriction    = UseRestriction.where(:name => 'Not For Loan').first
      item.checkout_type      = CheckoutType.where(:name => 'article').first
      item.rank               = 0
      item.shelf_id           = shelf.id        unless shelf.nil?
      item.call_number        = call_number     unless call_number.nil?
      if item.item_identifier.nil?
        while item.item_identifier.nil?
          create_item_identifier = Numbering.do_numbering(@numbering.name)
          exit_item_identifier = Item.where(:item_identifier => create_item_identifier).first
          item.item_identifier = create_item_identifier unless exit_item_identifier
        end
      end
      item.save!
      if @mode_item == "create"
        p "created item item_identifer: #{item.item_identifier}"
      else
        p "edited item item_identifer: #{item.item_identifier}"
      end
      item.patrons << import_textfile.user.library.patron if @mode_item == 'create'
      return item
    end

    def set_number(num)
      volume_number_string, issue_number_string = nil, nil
      unless num.nil?
        unless num.to_s.match(/\*/)
          volume_number_string, issue_number_string =  '', num 
        else
          volume_number_string = num.split('*')[0] rescue ''
          issue_number_string = num.split('*')[1] rescue ''
          volume_number_string = "" if volume_number_string.nil?
          issue_number_string = "" if issue_number_string.nil?
        end
      end
      return volume_number_string, issue_number_string
    end

    def set_page(page)
      start_page, end_page = nil, nil
      unless page.nil?
        if page.to_s.match(/\-/)
          start_page, end_page = page.split('-')[0], page.split('-')[1]
        elsif page.blank?
         start_page, end_page = "", ""
        else
          start_page, end_page = page, ""
        end
      end
      return start_page, end_page
    end

    def set_article_creatos(cell)
      return nil if cell.nil?
      creators = []
      if @manifestation_type.name == 'japanese_article'
        cell = cell.gsub('；', ';')
        creators = cell.split(';')
      else
        creators = cell.split(' ')
      end
      return creators
    end

    def set_article_subjects(cell)
      return nil if cell.nil?
      subjects = []
      if @manifestation_type.name == 'japanese_article'
        subjects = cell.gsub('；', ';').split(';')
      else
        #cell = cell.gsub('＊', '*')
        subjects = cell.split('*')
      end
      return subjects
    end
  end
end

# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportArticle

    def import_article(filename, id, extraparams)
      @manifestation_type = ManifestationType.find(extraparams['manifestation_type'].to_i)
      @resource_import_textfile_id = id
      @oo = Excelx.new(filename)

      extraparams["sheet"].each_with_index do |sheet, i|
        logger.info "num=#{i}  sheet=#{sheet}"
        @oo.default_sheet = sheet
        set_field(sheet)
        import_article_data(sheet)
      end
    end 

    def set_field(sheet)
      field_row_num = 1

      # read the field, then set field a hash
      @field = Hash::new
      @oo.first_column.upto(@oo.last_column) do |column|
        @field.store(@oo.cell(field_row_num, column).to_s, column)
      end
      # check that exist need fields
      require_field = [@field[I18n.t('resource_import_textfile.excel.article.original_title')]]
      import_textresult = ResourceImportTextresult.new(
        :resource_import_textfile_id => @resource_import_textfile_id,
        :extraparams                 => "{'sheet'=>'#{sheet}'}",
      )
      if require_field.reject{|field| field.to_s.strip == ""}.empty?
        import_textresult.error_msg = I18n.t('resource_import_textfile.error.article.head_is_blank', :sheet => sheet)
      else
        import_textresult.body      = @field.keys.join("\t")
        import_textresult.error_msg = I18n.t('resource_import_textfile.message.read_sheet', :sheet => sheet)
      end
      import_textresult.save

      raise if import_textresult.body.nil?
    end

    def import_article_data(sheet)
      first_data_row_num = 2
      num = { :manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0 }

      first_data_row_num.upto(@oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")

        datas = Hash::new
        @oo.first_column.upto(@oo.last_column) do |column|
           datas.store(column, fix_data(@oo.cell(row, column).to_s.strip))
        end
        import_textresult = ResourceImportTextresult.new(
          :resource_import_textfile_id => @resource_import_textfile_id,
          :body                        => datas.values.join("\t"),
          :extraparams                 => "{'sheet'=>'#{sheet}'}"
        )
        # check cell
        require_cell = [datas[@field[I18n.t('resource_import_textfile.excel.article.original_title')]]]
        if require_cell.reject{ |field| field.to_s.strip == "" }.empty?
          import_textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}] #{I18n.t('resource_import_textfile.error.article.cell_is_blank')}"
          import_textresult.save
          next
        end

        begin
          manifestation = fetch_article(datas)
          num[:manifestation_imported] += 1 if manifestation
          import_textresult.manifestation = manifestation
          if manifestation.valid?
            resource_import_textfile = ResourceImportTextfile.find(@resource_import_textfile_id)
            import_textresult.item = create_article_item(datas, manifestation, resource_import_textfile)
            manifestation.index
            num[:item_imported] +=1 if import_textresult.item

            if import_textresult.item.manifestation.next_reserve and import_textresult.item.item_identifier
              current_user = User.where(:username => 'admin').first
              import_textresult.item.retain(current_user) if import_textresult.item.available_for_retain?
              import_textresult.error_msg = I18n.t('resource_import_file.reserved_item',
                :username => import_textresult.item.reserve.user.username,
                :user_number => import_textresult.item.reserve.user.user_number)
            end
          else
            num[:failed] += 1
          end
        rescue => e
          import_textresult.error_msg = "FAIL[sheet:#{sheet} row:#{row}]: #{e.message}"
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
      #sm_complete!
      Rails.cache.write("manifestation_search_total", Manifestation.search.total)
      return num
    end

    def fetch_article(datas)
      ResourceImportTextfile.transaction do
        begin
          @mode = 'create'
          manifestation = exist_same_article?(datas)

          unless manifestation.nil?
            @mode = 'edit'
          else       
            manifestation = Manifestation.new(
              :original_title => datas[@field[I18n.t('resource_import_textfile.excel.article.original_title')]],
              :article_title  => datas[@field[I18n.t('resource_import_textfile.excel.article.title')]],
              :frequency      => Frequency.where(:name => 'unknown').first,
              :required_role  => Role.find('Guest'),
              :during_import  => true,
            )
          end

          start_page, end_page        = set_page(datas[@field[I18n.t('resource_import_textfile.excel.article.number_of_page')]])
          volume_number, issue_number = set_number(datas[@field[I18n.t('resource_import_textfile.excel.article.volume_number_string')]])

          manifestation.pub_date             = datas[@field[I18n.t('resource_import_textfile.excel.article.pub_date')]]
          manifestation.volume_number_string = volume_number
          manifestation.issue_number_string  = issue_number
          manifestation.start_page           = start_page
          manifestation.end_page             = end_page
          manifestation.manifestation_type   = @manifestation_type
          manifestation.save!

          if @mode == 'create'
            creators_cell   = datas[@field[I18n.t('resource_import_textfile.excel.article.creator')]]
            creators        = set_article_creatos(creators_cell)
            creators_list   = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
            creator_patrons = Patron.import_patrons(creators_list)
            manifestation.creators = creator_patrons
          end

          subjects_cell = datas[@field[I18n.t('resource_import_textfile.excel.article.subject')]]
          subjects_list = set_article_subjects(subjects_cell)
          subjects      = Subject.import_subjects (subjects_list)
          manifestation.subjects = subjects

          return manifestation
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def exist_same_article?(datas)
      original_title = datas[@field[I18n.t('resource_import_textfile.excel.article.original_title')]]
      article_title  = datas[@field[I18n.t('resource_import_textfile.excel.article.title')]]
      creators       = set_article_creatos(datas[@field[I18n.t('resource_import_textfile.excel.article.creator')]])

      article =  Manifestation.find(
        :first,
        :include => [:creators],
        :conditions => "original_title = \'#{original_title}\' and article_title = \'#{article_title}\' and creates.id is not null"
      )

      if article
        if article.creators.map{ |c| c.full_name }.sort == creators.sort
          return article
        else
          return nil
        end
      end
    end

    def create_article_item(datas, manifestation, resource_import_textfile)
      item = nil
      if @mode == 'create' or manifestation.items.nil?
        item = Item.new(
          :item_identifier    => Numbering.do_numbering('article'),
          :shelf              => resource_import_textfile.user.library.article_shelf,
          :circulation_status => CirculationStatus.where(:name => 'Not Available').first,
          :use_restriction_id => UseRestriction.where(:name => 'Not For Loan').first,
          :rank               => 0,
          :manifestation      => manifestation
        )
      else
        item = manifestation.items.first
      end
      item.call_number        = datas[@field[I18n.t('resource_import_textfile.excel.article.call_number')]]
      item.url                = datas[@field[I18n.t('resource_import_textfile.excel.article.url')]]
      item.save!
      item.patrons << resource_import_textfile.user.library.patron if @mode == 'create' or manifestation.items.nil?
      return item
    end

    def set_number(num)
      unless num.match(/\*/)
        return '', num 
      else
        volume_number_string = num.split('*')[0] rescue nil
        issue_number_string = num.split('*')[1] rescue nil
        return volume_number_string, issue_number_string
      end
    end

    def set_page(page)
      start_page, end_page = nil, nil
      page = page.to_s
      if page
        unless page.match(/\-/)
          start_page, end_page = page, page
        else
          start_page, end_page = page.split('-')[0], page.split('-')[1]
        end
      end
      return start_page, end_page
    end

    def set_article_creatos(cell)
      creators = []
      creators = @manifestation_type.name == 'japanese_article' ? cell.split(';') : cell.split(' ')
      return creators
    end

    def set_article_subjects(cell)
      subjects = []
      subjects = @manifestation_type.name == 'japanese_article' ? cell.split(';') : cell.split('*')
      return subjects
    end
  end
end

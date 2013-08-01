# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportArticle
    ARTICLE_COLUMNS         = %w(creator original_title title volume_number_string number_of_page pub_date call_number access_address subject)
    ARTICLE_REQUIRE_COLUMNS = %w(original_title)
    ARTICLE_FIELD_ROW       = 1
    ARTICLE_DATA_ROW        = 2

    def set_article_default
      # default setting: manifestation
      @article_default_language           = Language.where(:name => 'unknown').first
      @article_default_carrier_type       = CarrierType.where(:name => 'print').first
      @article_default_frequency          = Frequency.where(:name => 'unknown').first
      @article_default_role               = Role.find('Guest')
      @article_default_except_recent      = false
      # default setting: item
      @article_default_circulation_status = CirculationStatus.where(:name => 'Not Available').first
      @article_default_use_restriction    = UseRestriction.where(:name => 'Not For Loan').first
      @article_default_checkout_type      = CheckoutType.where(:name => 'article').first
      @article_default_rank               = 0
    end

    def import_article(sheet, errors)
      error_msg = check_article_header_field(sheet)
      unless error_msg
        import_textresult = ResourceImportTextresult.new(
          :resource_import_textfile_id => @resource_import_textfile.id,
          :extraparams                 => "{'sheet'=>'#{sheet}'}",
          :body                        => @field.values.join("\t"),
          :error_msg                   => I18n.t('resource_import_textfile.message.read_sheet', :sheet => sheet),
          :failed                      => true
        )
        # contain unknown field?
        article_headers = ARTICLE_COLUMNS.map { |c| I18n.t("resource_import_textfile.excel.article.#{c}") }
        unknown_fileds = @field.values.map { |name| name unless article_headers.include?(name) }.compact
        unless unknown_fileds.blank?
          import_textresult.error_msg += I18n.t('resource_import_textfile.message.out_of_manage', :columns => unknown_fileds.join(', ')) 
        end
        import_textresult.save!
        set_article_default
        import_article_data(sheet)
      else
        errors << { :msg => error_msg, :sheet => sheet }
      end
      return errors
    end 

    def check_article_header_field(sheet)
      # check1: sheet is blank
      return I18n.t('resource_import_textfile.error.blank_sheet', :sheet => sheet) unless @oo.first_column
      # check2: header has duplicate columns
      set_field
      return I18n.t('resource_import_textfile.error.overlap', :sheet => sheet) unless @field.values.uniq.size == @field.values.size
      # check3: header require field
      require_fields = ARTICLE_REQUIRE_COLUMNS.inject([]){ |list, column| list << I18n.t("resource_import_textfile.excel.article.#{column}") }
      return I18n.t('resource_import_textfile.error.article.head_is_blank', :sheet => sheet) unless (require_fields & @field.values) == require_fields

      return nil
    end

    def set_field 
      @field = Hash::new
      @oo.first_column.upto(@oo.last_column) do |column|
        column_name = @oo.cell(ARTICLE_FIELD_ROW, column).to_s.strip
        @field.store(column, column_name) unless column_name.blank?
      end
    end

    def set_datas(row)
      datas = Hash::new

      ARTICLE_COLUMNS.each do |column|
        value = nil
        invert_field = @field.invert
        if invert_field[I18n.t("resource_import_textfile.excel.article.#{column}")]
          cell = @oo.cell(row, invert_field[I18n.t("resource_import_textfile.excel.article.#{column}")])
          value = fix_data(cell)
        end        

        #case @field[column]
        case I18n.t("resource_import_textfile.excel.article.#{column}")
        when I18n.t('resource_import_textfile.excel.article.original_title')
          datas.store('original_title', value)
        when I18n.t('resource_import_textfile.excel.article.title')
          datas.store('article_title', value)
        when I18n.t('resource_import_textfile.excel.article.pub_date')
          datas.store('pub_date', value)
        when I18n.t('resource_import_textfile.excel.article.access_address')
          datas.store('access_address', value)
        when I18n.t('resource_import_textfile.excel.article.number_of_page')
          start_page, end_page = nil, nil
          unless value.nil? 
            page = value.to_s
            if page.present?
              if page.match(/\-/)
                start_page = fix_data(page.split('-')[0]) rescue ''
                end_page   = fix_data(page.split('-')[1]) rescue ''
              else
                start_page, end_page = page, ''
              end
            else
              start_page, end_page = '', ''
            end
          end
          datas.store('start_page', start_page)
          datas.store('end_page', end_page)
        when I18n.t('resource_import_textfile.excel.article.volume_number_string')
          volume_number_string, issue_number_string = nil, nil
          unless value.nil?
            value = value.to_s
            if value.present?
              if value.match(/\*/)
                volume_number_string = value.split('*')[0] rescue ''
                issue_number_string  = value.split('*')[1] rescue ''
              else
                volume_number_string, issue_number_string =  '', value
              end
            else
              volume_number_string, issue_number_string = '', ''
            end
          end
          datas.store('volume_number_string', volume_number_string)
          datas.store('issue_number_string', issue_number_string)
        when I18n.t('resource_import_textfile.excel.article.creator')
          datas.store('creators', @manifestation_type.name == 'japanese_article' ? value : value.to_s.gsub(' ', ';'))
        when I18n.t('resource_import_textfile.excel.article.subject')
          datas.store('subjects', @manifestation_type.name == 'japanese_article' ? value : value.to_s.gsub(/\*|＊/, ';'))
        when I18n.t('resource_import_textfile.excel.article.call_number')
          datas.store('call_number', value)
        end
      end
      p "---- datas --------------------"
      datas.each { |key, value| p "#{key}: #{value}" }
      return datas
    end

    def import_article_data(sheet)
      num = { 
        :manifestation_imported => 0,
        :item_imported          => 0,
        :manifestation_found    => 0,
        :item_found             => 0,
        :failed                 => 0 
      }

      ARTICLE_DATA_ROW.upto(@oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")
        origin_row = []
        @oo.first_column.upto(@oo.last_column) do |column|
          origin_row << @oo.cell(row, column).to_s.strip
        end
        import_textresult = ResourceImportTextresult.new(
          :resource_import_textfile_id => @resource_import_textfile.id,
          :body                        => origin_row.join("\t"),
          :extraparams                 => "{'sheet'=>'#{sheet}'}"
        )
        begin
          datas = set_datas(row)
          ARTICLE_REQUIRE_COLUMNS.each do |column|
            raise I18n.t('resource_import_textfile.error.article.cell_is_blank') if datas[column].nil? or datas[column].blank?
          end

          ActiveRecord::Base.transaction do
            item = same_article(datas)
            manifestation = create_article_manifestation(datas, item)
            if manifestation.valid?
              item = create_article_item(datas, manifestation, item)
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
        Sunspot.commit
        GC.start
      end
      Rails.cache.write("manifestation_search_total", Manifestation.search.total)
      return num
    end

    def create_article_manifestation(datas, item)
      mode = 'edit'
      manifestation = nil 
      if item
         manifestation = item.manifestation
      else       
        mode = 'create'
        manifestation = Manifestation.new(
          :carrier_type   => @article_default_carrier_type,
          :language       => @article_default_language,
          :frequency      => @article_default_frequency,
          :required_role  => @article_default_role,
          :except_recent  => @article_default_except_recent,
          :during_import  => true,
        )
      end
      p mode == 'create' ? "create new manifestation" : "edit manifestation / id:#{manifestation.id}" 

      manifestation.manifestation_type = @manifestation_type
      datas.each do |key, value|
        unless ['call_number', 'creators', 'subjects'].include?(key)
          manifestation[key] = value.to_s unless value.nil?
        end
      end
      manifestation.save!
      manifestation.creators = Patron.add_patrons(datas['creators']) unless datas['creators'].nil?
      manifestation.subjects = Subject.import_subjects(datas['subjects']) unless datas['subjects'].nil?
      return manifestation
    end

    def create_article_item(datas, manifestation, item)
      mode = 'edit'
      unless item 
        if manifestation.items.size < 1
          mode = 'create'
          item = Item.new
        else
          item = manifestation.items.order('created_at asc').first
        end
      end
      p mode == 'create' ? "create new item" : "edit item / id: #{item.id} / item_identifer: #{item.item_identifier}"

      item.circulation_status = @article_default_circulation_status
      item.use_restriction    = @article_default_use_restriction
      item.checkout_type      = @article_default_checkout_type
      item.rank               = @article_default_rank
      item.shelf_id           = @resource_import_textfile.user.library.article_shelf.id
      item.call_number        = datas['call_number'].to_s unless datas['call_number'].nil?
      while item.item_identifier.nil?
        item_identifier = Numbering.do_numbering(@numbering.name)
        item.item_identifier   = item_identifier unless Item.where(:item_identifier => item_identifier).first
      end
      item.save!
      item.patrons << @resource_import_textfile.user.library.patron if mode == 'create'
      return item
    end

    def same_article(datas)
      conditions = ["((manifestations).manifestation_type_id = \'#{@manifestation_type.id}\')"]
      datas.each do |key, value|
        case key
        when 'creators', 'subjects'
          conditions << "#{key == 'creators' ? 'creates' : 'subjects'}.id IS #{'NOT' unless value.nil? or value.blank?} NULL"
        else
          model = 'manifestations'
          model = 'items' if key == 'call_number'
          if value.nil? or value.blank?
            conditions << "((#{model}).#{key} IS NULL OR (#{model}).#{key} = '')"
          else
            conditions << "((#{model}).#{key} = \'#{value.to_s.gsub("'", "''")}\')"
          end 
        end
      end
      conditions = conditions.join(' AND ')
      p "---- conditions --------------------"
      p conditions

      article = Item.find(
        :first,
        :include => [:manifestation => [:creators, :subjects]],
        :conditions => conditions,
        :order => "items.created_at asc"
      )
      if article
        creators = article.manifestation.creators
        subjects = article.manifestation.subjects
        if (creators.blank? and (datas['creators'].nil? or datas['creators'].blank?)) or (creators.pluck(:full_name).sort == datas['creators'].gsub('；', ';').split(/;/).sort)
          if (subjects.blank? and (datas['subjects'].nil? or datas['subjects'].blank?)) or (subjects.pluck(:term).sort == datas['subjects'].gsub('；', ';').split(/;/).sort)
            return article
          end
        end
      end
      return nil
    end
  end
end

# -*- encoding: utf-8 -*-
module EnjuTrunk
  module ExcelfileImportArticle
    def import_article(filename, id, extraparams)
      manifestation_type = ManifestationType.find(eval(extraparams['manifestation_type']).to_i)

      oo = Excelx.new(filename)
      extraparams["sheet"].each_with_index do |sheet, i|
        logger.info "num=#{i}  sheet=#{sheet}"
        oo.default_sheet = sheet
        import_article_start(oo, id, manifestation_type)
      end
    end 

    def import_article_start(oo, resource_import_textfile_id, manifestation_type)
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
      # check head
      require_head_article = [field[I18n.t('resource_import_textfile.excel.article.original_title')]]
      if require_head_article.reject{|field| field.to_s.strip == ""}.empty?
        import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => '' )
        import_textresult.error_msg = I18n.t('resource_import_textfile.error.article.head_is_blank', :sheet => oo.default_sheet)
        import_textresult.save
        raise
      end

      first_row_num.upto(oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")
        body = []
        first_column_num.upto(oo.last_column) do |column|
          body << oo.cell(row, column)
        end
        import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => body.join("\t"))
        # check cell
        require_cell_article = [oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.original_title')]).to_s.strip]
        if require_cell_article.reject{|field| field.to_s.strip == ""}.empty?
          import_textresult.error_msg = "FAIL[sheet:#{oo.default_sheet} row:#{row}] #{I18n.t('resource_import_textfile.error.article.cell_is_blank')}"
          import_textresult.save
          next
        end

        begin
          exist_same_article?(oo, row, field, manifestation_type)
          manifestation = fetch_article(oo, row, field, manifestation_type)
          num[:manifestation_imported] += 1 if manifestation
          import_textresult.manifestation = manifestation

          if manifestation.valid?
            resource_import_textfile = ResourceImportTextfile.find(resource_import_textfile_id)
            import_textresult.item = create_article_item(oo, row, field, manifestation, resource_import_textfile)
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
          import_textresult.error_msg = "FAIL[sheet:#{oo.default_sheet} row:#{row}]: #{e.message}"
          Rails.logger.info("FAIL[sheet:#{oo.default_sheet} row:#{row}] resource registration failed: column #{row}: #{e.message}")
          Rails.logger.info("FAIL[sheet:#{oo.default_sheet} row:#{row}] #{$@}")
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

    def exist_same_article?(oo, row, field, manifestation_type)
      # check field
      original_title = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.original_title')]).to_s.strip)
      article_title  = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.title')]).to_s.strip)
      call_number    = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.call_number')]).to_s.strip)
      creators       = set_article_creatos(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.creator')]).to_s.strip, manifestation_type)     
      subjects       = set_article_subjects(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.subject')]).to_s.strip, manifestation_type)

      article = Manifestation.find(
        :first,
        :joins => :items,
        :include => [:creators, :subjects],
        :conditions => {
          :original_title => original_title,
          :article_title  => article_title,
          :items => { :call_number  => call_number },
        }
      ) rescue nil
      if article
        if article.creators.map{ |c| c.full_name }.sort == creators.sort and article.subjects.map{ |s| s.term }.sort == subjects.sort
          raise I18n.t('resource_import_textfile.error.article.exist_same_article')
        end
      end
    end

    def fetch_article(oo, row, field, manifestation_type)
      manifestation = nil

      # 更新、削除はどうする？
      title = {}
      title[:original_title] = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.original_title')]).to_s.strip)
      title[:article_title]  = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.title')]).to_s.strip)
      start_page, end_page   = set_page(fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.number_of_page')]).to_s.strip))
      number_field = field[I18n.t('resource_import_textfile.excel.article.volume_number_string')]
      volume_number_string, issue_number_string = set_number(fix_data(oo.cell(row, number_field).to_s.strip), manifestation_type)

      ResourceImportTextfile.transaction do
        begin
          manifestation                      = Manifestation.new(title)
          manifestation.pub_date             = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.pub_date')]).to_s.strip)
          manifestation.volume_number_string = volume_number_string
          manifestation.issue_number_string  = issue_number_string
          manifestation.start_page           = start_page
          manifestation.end_page             = end_page
          manifestation.manifestation_type   = manifestation_type
          manifestation.frequency            = Frequency.where(:name => 'unknown').first
          manifestation.required_role        = Role.find('Guest')
          manifestation.during_import        = true
          manifestation.save!

          creators_cell = oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.creator')]).to_s.strip
          creators = set_article_creatos(creators_cell, manifestation_type)
          creators_list = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
          creator_patrons = Patron.import_patrons(creators_list)
          manifestation.creators << creator_patrons

          subjects_cell = oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.subject')]).to_s.strip
          subjects_list = set_article_subjects(subjects_cell, manifestation_type)
          subjects = Subject.import_subjects (subjects_list)
          manifestation.subjects << subjects

          #TODO: manifestationをsaveする前にcreateが先に呼ばれてしまうので一旦manifestationの作成を行ってから追加する
          manifestation.save!
          return manifestation
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def set_number(num, manifestation_type)
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

    def set_article_creatos(cell, manifestation_type)
      creators = []
      creators = manifestation_type.name == 'japanese_article' ? cell.split(';') : cell.split(' ')
      return creators
    end

    def set_article_subjects(cell, manifestation_type)
      subjects = []
      subjects = manifestation_type.name == 'japanese_article' ? cell.split(';') : cell.split('*')
      return subjects
    end

    def create_article_item(oo, row, field, manifestation, resource_import_textfile)
      item = import_item(manifestation, {
        :call_number        => oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.call_number')]).to_s.strip,
        :url                => oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.url')]).to_s.strip,
        :item_identifier    => Numbering.do_numbering('article'),
        :shelf              => resource_import_textfile.user.library.article_shelf,
        :circulation_status => CirculationStatus.where(:name => 'Not Available').first,
        :use_restriction_id => UseRestriction.where(:name => 'Not For Loan').first,
        :rank               => 0,
      })
      return item
    end
  end
end

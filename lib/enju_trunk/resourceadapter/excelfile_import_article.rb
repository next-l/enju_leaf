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

      # check cell 
      if [field[I18n.t('resource_import_textfile.excel.article.original_title')]].reject{|field| field.to_s.strip == ""}.empty?
        raise "You should specify original_tile in the first line"
      end

      first_row_num.upto(oo.last_row) do |row|
        Rails.logger.info("import block start. row_num=#{row}")
        body = []
        first_column_num.upto(oo.last_column) do |column|
          body << oo.cell(row, column)
        end
        import_textresult = ResourceImportTextresult.create!(:resource_import_textfile_id => resource_import_textfile_id, :body => body.join("\t"))

        begin
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
          import_textresult.error_msg = "FAIL[#{row}]: #{e.message}"
          Rails.logger.info("FAIL[#{row} resource registration failed: column #{row}: #{e.message}")
          Rails.logger.info("FAIL[#{row} #{$@}")
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

    def fetch_article(oo, row, field, manifestation_type)
      manifestation = nil

      # 更新、削除はどうする？
      title = {}
      title[:original_title] = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.original_title')]).to_s.strip)
      title[:article_title]  = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.title')]).to_s.strip)
      start_page, end_page = set_page(fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.number_of_page')]).to_s.strip))
      number = fix_data(oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.volume_number_string')]).to_s.strip)
      volume_number_string = number.split('*')[0] rescue nil
      issue_number_string = number.split('*')[1] rescue nil

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

          creators = []
          if manifestation_type.name == 'japanese_article'
            creators = oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.creator')]).to_s.strip.split('；')
          else
            creators = oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.creator')]).to_s.strip.split(' ')
          end
          creators_list = creators.inject([]){ |list, creator| list << {:full_name => creator.to_s.strip, :full_name_transcription => "" } }
          creator_patrons = Patron.import_patrons(creators_list)
#TODO:!!!!!!!!!!!!!!
#          manifestation.creators << creator_patrons

          subjects = import_article_subject(oo, row, field, manifestation_type)
#TODO:!!!!!!!!!!!!!!
#          manifestation.subjects << subjects

          manifestation.save!
          return manifestation
        rescue Exception => e
          p "error at fetch_new: #{e.message}"
          raise e
        end
      end
    end

    def set_page(page)
      start_page, end_page = nil, nil
      if page.match(/-/) .nil?
        start_page, end_page = page, page
      else
        start_page, end_page = page.split('-')[0], page.split('-')[1]
      end
      return start_page, end_page
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

    def import_article_subject(oo, row, field, manifestation_type)
      subjects = []
      subject_list = nil
      if manifestation_type.name == 'japanese_article'
        subject_list = (oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.subject')]).to_s).split('；')
      else
        subject_list = (oo.cell(row, field[I18n.t('resource_import_textfile.excel.article.subject')]).to_s).split('*')
      end
      subject_list.each do |s|
        subject = Subject.where(:term => s.to_s.strip).first
        unless subject
          # TODO: Subject typeの設定
          subject = Subject.new(
            :term => s.to_s.strip,
            :subject_type_id => 1,
          )
          subject.save
        end
        subjects << subject
      end
      subjects
    end
  end
end

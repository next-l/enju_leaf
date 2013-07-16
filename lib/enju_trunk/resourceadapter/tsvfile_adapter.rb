# -*- encoding: utf-8 -*-
class Tsvfile_Adapter < EnjuTrunk::ResourceAdapter::Base

  attr_accessor :import_id

  def self.display_name
    "TSVファイル"
  end

  def self.template_filename_show
    "tsvfile_show.html.erb"
  end

  def self.template_filename_edit
    "tsvfile_edit.html.erb"
  end

  def import_from_file(filename)
    # based on app/models/resource_import_file.rb#import
    resource_import_textfile = ResourceImportTextfile.find(@import_id)
    num = {:manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0}
    row_num = 2
    rows = open_import_file(filename)

    field = rows.first
    if [field['isbn'], field['original_title']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify isbn or original_tile in the first line"
    end

    rows.each_with_index do |row, index|
      Rails.logger.info("import block start. row_num=#{row_num} index=#{index}")

      next if row['dummy'].to_s.strip.present?

      import_result = ResourceImportTextresult.create!({:resource_import_textfile_id => self.import_id, :body => row.fields.join("\t")})

      item_identifier = row['item_identifier'].to_s.strip
      item = Item.where(:item_identifier => item_identifier).first
      if item
        import_result.item = item
        import_result.manifestation = item.manifestation
        import_result.error_msg = "FAIL[#{row_num}]: #{item_identifier} already exists"
        import_result.save!
        num[:item_found] += 1
        row_num += 1
        next
      end

      if row['identifier'].present?
        manifestation = Manifestation.where(:identifier => row['identifier'].to_s.strip).first
      end

      if row['nbn'].present?
        manifestation = Manifestation.where(:nbn => row['nbn'].to_s.strip).first
      end

      unless manifestation
        if row['isbn'].present?
          isbn = Lisbn.new(row['isbn'])
          m = Manifestation.find_by_isbn(isbn)
          if m
            if m.series_statement
              manifestation = m
            end
          end
        end
      end
      num[:manifestation_found] += 1 if manifestation

      has_error = false
      unless manifestation
        series_statement = find_series_statement(row)
        begin
          manifestation = Manifestation.import_isbn(isbn)
          if manifestation
            manifestation.series_statement = series_statement
            manifestation.save!
          end
        rescue EnjuNdl::InvalidIsbn
          import_result.error_msg = "FAIL[#{row_num}]: "+I18n.t('resource_import_file.invalid_isbn', :isbn => isbn)
          Rails.logger.error "FAIL[#{row_num}]: import_isbn catch EnjuNdl::InvalidIsbn isbn: #{isbn}"
          manifestation = nil
          num[:failed] += 1
          has_error = true
        rescue EnjuNdl::RecordNotFound
          import_result.error_msg = "FAIL[#{row_num}]: "+I18n.t('resource_import_file.record_not_found', :isbn => isbn)
          Rails.logger.error "FAIL[#{row_num}]: import_isbn catch EnjuNdl::RecordNotFound isbn: #{isbn}"
          manifestation = nil
          num[:failed] += 1
          has_error = true
        rescue ActiveRecord::RecordInvalid  => e
          import_result.error_msg = "FAIL[#{row_num}]: fail save manifestation. (record invalid) #{e.message}"
          Rails.logger.error "FAIL[#{row_num}]: fail save manifestation. (record invalid) #{e.message}"
          Rails.logger.error "FAIL[#{row_num}]: #{$@}"
          manifestation = nil
          num[:failed] += 1
          has_error = true
        rescue ActiveRecord::StatementInvalid => e
          import_result.error_msg = "FAIL[#{row_num}]: fail save manifestation. (statement invalid) #{e.message}"
          Rails.logger.error "FAIL[#{row_num}]: fail save manifestation. (statement invalid) #{e.message}"
          Rails.logger.error "FAIL[#{row_num}]: #{$@}"
          manifestation = nil
          num[:failed] += 1
          has_error = true
        rescue => e
          import_result.error_msg = "FAIL[#{row_num}]: fail save manifestation. #{e.message}"
          Rails.logger.error "FAIL[#{row_num}]: fail save manifestation. #{e.message}"
          Rails.logger.error "FAIL[#{row_num}]: #{$@}"
          manifestation = nil
          num[:failed] += 1
          has_error = true
        end
        num[:manifestation_imported] += 1 if manifestation
      end

      Rails.logger.info "@@ step 100"
      unless has_error
        begin
          unless manifestation
            manifestation = fetch(row)
            num[:manifestation_imported] += 1 if manifestation
          end
          import_result.manifestation = manifestation

          Rails.logger.info "@@ step 110"
          if manifestation.valid? and item_identifier.present?
            Rails.logger.info "@@ step 200"
            import_result.item = create_item(row, manifestation)
            Rails.logger.info "@@ step 202"
            manifestation.index
            num[:item_imported] +=1 if import_result.item

            if import_result.item.manifestation.next_reserve
              current_user = User.where(:username => 'admin').first
              import_result.item.retain(current_user) if import_result.item.available_for_retain?           
              import_result.error_msg = I18n.t('resource_import_file.reserved_item', :username => import_result.item.reserve.user.username, :user_number => import_result.item.reserve.user.user_number)
            end
          else
            num[:failed] += 1
          end
        rescue => e
          import_result.error_msg = "FAIL[#{row_num}]: #{e.message}"
          Rails.logger.info("FAIL[#{row_num} resource registration failed: column #{row_num}: #{e.message}")
          Rails.logger.info("FAIL[#{row_num} #{$@}")
          num[:failed] += 1
        end
      end

      import_result.save!

      if row_num % 50 == 0
        Sunspot.commit
        GC.start
      end
      row_num += 1
    end

    resource_import_textfile.update_attribute(:imported_at, Time.zone.now)
    Sunspot.commit
    rows.close
    resource_import_textfile.sm_complete!
    Rails.cache.write("manifestation_search_total", Manifestation.search.total)
    return num
  end

  def import(id, filename, user_id, extraparameters = {})
    logger.info "#{Time.now} start import #{self.class.display_name}"
    logger.info "id=#{id} filename=#{filename}"

    @import_id = id
    @user_id = user_id

    Benchmark.bm do |x|
      x.report {
        num = import_from_file(filename)
        logger.info "result: #{num}" 
      }
    end

    logger.info "#{Time.now} end import #{self.class.display_name}"
  end

  private
  def open_import_file(filename)
    tempfile = Tempfile.new('resource_import_file')
    if Setting.uploaded_file.storage == :s3
      uploaded_file_path = open(self.resource_import.expiring_url(10)).path
    else
      uploaded_file_path = filename
    end
    
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    file = CSV.open(tempfile.path, :col_sep => "\t")
    header, index = get_header(file)
    rows = CSV.open(tempfile.path, :headers => header, :col_sep => "\t")
    index.times do
      rows.shift
    end

    ResourceImportTextresult.create({:resource_import_textfile_id => self.import_id, :body => header.join("\t"), :error_msg => "HEADER DATA"})
    tempfile.close(true)
    file.close
    rows
  end

  def import_subject(row)
    subjects = []
    row['subject'].to_s.split(';').each do |s|
      subject = Subject.where(:term => s.to_s.strip).first
      unless subject
        # TODO: Subject typeの設定
        subject = Subject.create(:term => s.to_s.strip, :subject_type_id => 1)
      end
      subjects << subject
    end
    subjects
  end

  def select_item_shelf(row)
    Rails.logger.debug "@@select_item_shelf self"
    Rails.logger.debug "user_id=#{@user_id}"
    Rails.logger.debug self
    shelf = Shelf.where(:name => row['shelf'].to_s.strip).first 
    user = User.find(@user_id) rescue nil
    if shelf.nil? && user
      shelf = user.library.in_process_shelf
    end
    unless shelf 
      shelf = Shelf.web
    end
    shelf
  end

  def import_item(manifestation, options)
    item = Item.new(options)
    item.manifestation = manifestation
    if item.save!
      item.patrons << options[:shelf].library.patron
    end
    return item
  end

  def create_item(row, manifestation)
    circulation_status = CirculationStatus.where(:name => row['circulation_status'].to_s.strip).first || CirculationStatus.where(:name => 'Available On Shelf').first
    shelf = select_item_shelf(row)
    bookstore = Bookstore.where(:name => row['bookstore'].to_s.strip).first
    acquired_at = Time.zone.parse(row['acquired_at']) rescue nil
    use_restriction = UseRestriction.where(:name => row['use_restriction'].to_s.strip).first
    use_restriction_id = use_restriction.id if use_restriction
    item = import_item(manifestation, {
      :item_identifier => row['item_identifier'],
      :price => row['item_price'],
      :call_number => row['call_number'].to_s.strip,
      :circulation_status => circulation_status,
      :shelf => shelf,
      :acquired_at => acquired_at,
      :bookstore => bookstore,
      :use_restriction_id => use_restriction_id
    })
    item
  end

  def fetch(row, options = {:edit_mode => 'create'})
    shelf = Shelf.where(:name => row['shelf'].to_s.strip).first || Shelf.web
    case options[:edit_mode]
    when 'create'
      manifestation = nil
    when 'update'
      manifestation = Item.where(:item_identifier => row['item_identifier'].to_s.strip).first.try(:manifestation)
    end
    title = {}
    title[:original_title] = row['original_title'].to_s.strip
    title[:title_transcription] = row['title_transcription'].to_s.strip
    title[:title_alternative] = row['title_alternative'].to_s.strip
    if options[:edit_mode] == 'update'
      title[:original_title] = manifestation.original_title if row['original_title'].to_s.strip.blank?
      title[:title_transcription] = manifestation.title_transcription if row['title_transcription'].to_s.strip.blank?
      title[:title_alternative] = manifestation.title_alternative if row['title_alternative'].to_s.strip.blank?
    end
    #title[:title_transcription_alternative] = row['title_transcription_alternative']
    ##    if title[:original_title].blank? and options[:edit_mode] == 'create'
    ##      return nil
    ##    end

    if row['isbn'] && row['isbn'].preset? 
      if Lisbn.new(row['isbn'].to_s.strip).valid?
        isbn = Lisbn.new(row['isbn'])
      end
    end

    width = NKF.nkf('-eZ1', row['width'].to_s).gsub(/\D/, '').to_i
    height = NKF.nkf('-eZ1', row['height'].to_s).gsub(/\D/, '').to_i
    depth = NKF.nkf('-eZ1', row['depth'].to_s).gsub(/\D/, '').to_i
    end_page = NKF.nkf('-eZ1', row['number_of_pages'].to_s).gsub(/\D/, '').to_i
    language = Language.where(:name => row['language'].to_s.strip.camelize).first
    language = Language.where(:iso_639_2 => row['language'].to_s.strip.downcase).first unless language
    language = Language.where(:iso_639_1 => row['language'].to_s.strip.downcase).first unless language
    if end_page >= 1
      start_page = 1
    else
      start_page = nil
      end_page = nil
    end

    ResourceImportTextfile.transaction do
      creators = row['creator'].to_s.split(';')
      creator_transcriptions = row['creator_transcription'].to_s.split(';')
      creators_list = creators.zip(creator_transcriptions).map{|f,t| {:full_name => f.to_s.strip, :full_name_transcription => t.to_s.strip}}
      contributors = row['contributor'].to_s.split(';')
      contributor_transcriptions = row['contributor_transcription'].to_s.split(';')
      contributors_list = contributors.zip(contributor_transcriptions).map{|f,t| {:full_name => f.to_s.strip, :full_name_transcription => t.to_s.strip}}
      publishers = row['publisher'].to_s.split(';')
      publisher_transcriptions = row['publisher_transcription'].to_s.split(';')
      publishers_list = publishers.zip(publisher_transcriptions).map{|f,t| {:full_name => f.to_s.strip, :full_name_transcription => t.to_s.strip}}
      creator_patrons = Patron.import_patrons(creators_list)
      contributor_patrons = Patron.import_patrons(contributors_list)
      publisher_patrons = Patron.import_patrons(publishers_list)
      #classification = Classification.where(:category => row['classification'].to_s.strip).first
      subjects = import_subject(row)
      series_statement = import_series_statement(row)
      case options[:edit_mode]
      when 'create'
        work = ResourceImportFile.import_work(title, creator_patrons, options) # self.class.import_work(title, creator_patrons, options)
        work.series_statement = series_statement
        work.subjects << subjects
        expression = ResourceImportFile.import_expression(work, contributor_patrons) # self.class.import_expression(work, contributor_patrons)
      when 'update'
        expression = manifestation
        work = expression
        work.series_statement = series_statement
        work.subjects = subjects
        work.creators = creator_patrons
        expression.contributors = contributor_patrons
      end

      manifestation = ResourceImportFile.import_manifestation(expression, publisher_patrons, { # self.class.import_manifestation(expression, publisher_patrons, {
        :original_title => title[:original_title],
        :title_transcription => title[:title_transcription],
        :title_alternative => title[:title_alternative],
        :title_alternative_transcription => title[:title_alternative_transcription],
        :isbn => isbn,
        :wrong_isbn => row['wrong_isbn'],
        :issn => row['issn'],
        :lccn => row['lccn'],
        :nbn => row['nbn'],
        :pub_date => row['pub_date'],
        :volume_number_string => row['volume_number_string'],
        :issue_number_string => row['issue_number_string'],
        :serial_number_string => row['serial_number_string'],
        :edition => row['edition'],
        :width => width,
        :depth => depth,
        :height => height,
        :price => row['manifestation_price'],
        :description => row['description'],
        :note => row['note'],
        :series_statement => series_statement,
        :start_page => start_page,
        :end_page => end_page,
        :access_address => row['access_addres'],
        :identifier => row['identifier']
      },
        {
        :edit_mode => options[:edit_mode]
      })
    end

    manifestation.required_role = Role.where(:name => row['required_role_name'].to_s.strip.camelize).first || Role.find('Guest')
    manifestation.language = language
    begin
      manifestation.save!
      return manifestation
    rescue Exception => e
      p "error at fetch_new: #{e.message}"
      raise e
    end
  end

  def import_series_statement(row)
    issn = Lisbn.new(row['issn'].to_s)
    series_statement = find_series_statement(row)
    unless series_statement
      if row['series_statement_original_title'].to_s.strip.present?
        series_statement = SeriesStatement.new(
          :original_title => row['series_statement_original_title'].to_s.strip,
          :title_transcription => row['series_statement_title_transcription'].to_s.strip,
          :series_statement_identifier => row['series_statement_identifier'].to_s.strip
        )
        if issn.present?
          series_statement.issn = issn
        end
        if row['periodical'].to_s.strip.present?
          series_statement.periodical = true
        end
        series_statement.save!
        if series_statement.periodical
          SeriesStatement.transaction do
            creators = row['series_statement_creator'].to_s.split(';')
            creator_transcriptions = row['series_statement_creator_transcription'].to_s.split(';')
            creators_list = creators.zip(creator_transcriptions).map{|f,t| {:full_name => f.to_s.strip, :full_name_transcription => t.to_s.strip}}
            creator_patrons = Patron.import_patrons(creators_list)
            series_statement.initial_manifestation.creators << creator_patrons
          end
        end
      end
    end
    if series_statement
      series_statement
    else
      nil
    end
  end

  def find_series_statement(row)
    issn = Lisbn.new(row['issn'].to_s)
    series_statement_identifier = row['series_statement_identifier'].to_s.strip
    series_statement = SeriesStatement.where(:issn => issn).first if issn.present?
    unless series_statement
      series_statement = SeriesStatement.where(:series_statement_identifier => series_statement_identifier).first if series_statement_identifier.present?
    end
    series_statement = SeriesStatement.where(:original_title => row['series_statement_original_title'].to_s.strip).first unless series_statement
    series_statement
  end

  def get_header(file)
    file.each_with_index do |f, i|
      return f, i if f.include?("kbn")
    end
    return false
  end

end
EnjuTrunk::ResourceAdapter::Base.add(Tsvfile_Adapter)

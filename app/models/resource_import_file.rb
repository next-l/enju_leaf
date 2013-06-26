class ResourceImportFile < ActiveRecord::Base
  attr_accessible :resource_import, :edit_mode
  include ImportFile
  default_scope :order => 'id DESC'
  scope :not_imported, where(:state => 'pending', :imported_at => nil)
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if Setting.uploaded_file.storage == :s3
    has_attached_file :resource_import, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
      :path => "resource_import_files/:id/:filename",
      :s3_permissions => :private
  else
    has_attached_file :resource_import, :path => ":rails_root/private:url"
  end
  validates_attachment_content_type :resource_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values', 'application/octet-stream']
  validates_attachment_presence :resource_import
  belongs_to :user, :validate => true
  has_many :resource_import_results
  before_create :set_digest

  state_machine :initial => :pending do
    event :sm_start do
      transition [:pending, :started] => :started
    end

    event :sm_complete do
      transition :started => :completed
    end

    event :sm_fail do
      transition :started => :failed
    end
  end

  def set_digest(options = {:type => 'sha1'})
    if File.exists?(resource_import.queued_for_write[:original])
      self.file_hash = Digest::SHA1.hexdigest(File.open(resource_import.queued_for_write[:original].path, 'rb').read)
    end
  end

  def import_start
    sm_start!
    case edit_mode
    when 'create'
      import
    when 'update'
      modify
    when 'destroy'
      remove
    else
      import
    end
  end

  def import
    num = {:manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0}
    row_num = 2
    rows = open_import_file
    field = rows.first
    if [field['isbn'], field['original_title']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify isbn or original_tile in the first line"
    end

    rows.each_with_index do |row, index|
      Rails.logger.info("import block start. row_num=#{row_num} index=#{index}")

      next if row['dummy'].to_s.strip.present?
      import_result = ResourceImportResult.create!(:resource_import_file => self, :body => row.fields.join("\t"))

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
          debugger

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

      unless has_error
        begin
          unless manifestation
            manifestation = fetch(row)
            num[:manifestation_imported] += 1 if manifestation
          end
          import_result.manifestation = manifestation

          if manifestation.valid? and item_identifier.present?
            import_result.item = create_item(row, manifestation)
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

    self.update_attribute(:imported_at, Time.zone.now)
    Sunspot.commit
    rows.close
    sm_complete!
    Rails.cache.write("manifestation_search_total", Manifestation.search.total)
    return num
  end

  def self.import_work(title, patrons, options = {:edit_mode => 'create'})
    work = Manifestation.new(title)
    case options[:edit_mode]
    when 'create'
      work.creators << patrons
    when 'update'
      work.creators = patrons
    end
    work
  end

  def self.import_expression(work, patrons, options = {:edit_mode => 'create'})
    expression = work
    case options[:edit_mode]
    when 'create'
      expression.contributors << patrons
    when 'update'
      expression.contributors = patrons
    end
    expression
  end

  def self.import_manifestation(expression, patrons, options = {}, edit_options = {:edit_mode => 'create'})
    manifestation = expression
    manifestation.update_attributes!(options.merge(:during_import => true))
    case edit_options[:edit_mode]
    when 'create'
      manifestation.publishers << patrons
    when 'update'
      manifestation.publishers = patrons
    end
    manifestation
  end

  def self.import_item(manifestation, options)
    options = {:shelf => Shelf.web}.merge(options)
    item = Item.new(options)
    item.manifestation = manifestation
    if item.save!
      item.patrons << options[:shelf].library.patron
    end
    item
  end

  def self.update_item(item, options = {})
    item.update_attributes!(options)
  end

=begin
#TODO
  def import_marc(marc_type)
    file = File.open(self.resource_import.path)
    case marc_type
    when 'marcxml'
      reader = MARC::XMLReader.new(file)
    else
      reader = MARC::Reader.new(file)
    end
    file.close

    #when 'marc_xml_url'
    #  url = URI(params[:marc_xml_url])
    #  xml = open(url).read
    #  reader = MARC::XMLReader.new(StringIO.new(xml))
    #end

    # TODO
    for record in reader
      manifestation = Manifestation.new(:original_title => expression.original_title)
      manifestation.carrier_type = CarrierType.find(1)
      manifestation.frequency = Frequency.find(1)
      manifestation.language = Language.find(1)
      manifestation.save

      full_name = record['700']['a']
      publisher = Patron.find_by_full_name(record['700']['a'])
      if publisher.blank?
        publisher = Patron.new(:full_name => full_name)
        publisher.save
      end
      manifestation.publishers << publisher
    end
  end
=end

  def self.import(id = nil)
    if !id.nil?
      file = ResourceImportFile.find(id) rescue nil
      file.import_start unless file.nil?
    else
      ResourceImportFile.not_imported.each do |file|
        file.import_start
      end
    end
  rescue Exception => e
    logger.info "#{Time.zone.now} importing resources failed! #{e}"
  end

  #def import_jpmarc
  #  marc = NKF::nkf('-wc', self.db_file.data)
  #  marc.split("\r\n").each do |record|
  #  end
  #end

  def modify
    rows = open_import_file
    row_num = 2
    field = rows.first
    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      import_result = ResourceImportResult.create!(:resource_import_file => self, :body => row.fields.join("\t"))
      item_identifier = row['item_identifier'].to_s.strip
      item = Item.where(:item_identifier => item_identifier).first if item_identifier.present?
      if item.try(:manifestation)
        begin
          fetch(row, :edit_mode => 'update')
          options = {}
          checkout_type = CheckoutType.where(:name => row['checkout_type'].to_s.strip).first if row['checkout_type']
          options[:checkout_type] = checkout_typs if checkout_type
          shelf = Shelf.where(:name => row['shelf'].to_s.strip).first if row['shelf']
          options[:shelf] = shelf if shelf
          circulation_status = CirculationStatus.where(:name => row['circulation_status'].to_s.strip).first if row['circulation_status']
          options[:circulation_status] = circulation_status if circulation_status
          if row['include_supplements']
            if row['include_supplements'].blank?
              options[:include_supplements] = false
            else
              options[:include_supplements] = true
            end
          end
          bookstore = Bookstore.where(:name => row['bookstore'].to_s.strip).first if row['bookstore']
          options[:bookstore] = bookstore if bookstore
          options[:call_number] = row['call_number'].to_s.strip if row['call_number'] && !row['call_number'].blank?
          options[:price] = row['price'] if row['price'] && !row['price'].blank?
          self.class.update_item(item, options)
          import_result.manifestation = item.manifestation
          import_result.item = item

          import_result.error_msg = I18n.t('resource_import_file.reserved_item', :username => import_result.item.reserve.user.username, :user_number => import_result.item.reserve.user.user_number) if import_result.item.reserve
        rescue Exception => e
          import_result.error_msg = "FAIL[#{row_num}]: #{e.message}"
          Rails.logger.info("resource registration failed: column #{row_num}: #{e.message}")
        end
      else
        import_result.error_msg = "FAIL[#{row}]: #{item_identifier} does not exist"
      end
      import_result.save!
      row_num += 1
    end
  end

  def remove
    rows = open_import_file
    rows.each do |row|
      item_identifier = row['item_identifier'].to_s.strip
      item = Item.where(:item_identifier => item_identifier).first
      if item
        item.destroy if item.deletable?
      end
    end
  end

  private
  def open_import_file
    tempfile = Tempfile.new('patron_import_file')
    if Setting.uploaded_file.storage == :s3
      uploaded_file_path = open(self.resource_import.expiring_url(10)).path
    else
      uploaded_file_path = self.resource_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    if RUBY_VERSION > '1.9'
      file = CSV.open(tempfile.path, :col_sep => "\t")
      header, index = get_header(file)
      rows = CSV.open(tempfile.path, :headers => header, :col_sep => "\t")
      index.times do
        rows.shift
      end
    else
      file = FasterCSV.open(tempfile.path, :col_sep => "\t")
      header = file.first
      rows = FasterCSV.open(tempfile.path, :headers => header, :col_sep => "\t")
    end
    ResourceImportResult.create(:resource_import_file => self, :body => header.join("\t"), :error_msg => "HEADER DATA")
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
    shelf = Shelf.where(:name => row['shelf'].to_s.strip).first 
    if shelf.nil? && self.user
      shelf = self.user.library.in_process_shelf
    end
    unless shelf 
      shelf = Shelf.web
    end
    shelf
  end

  def create_item(row, manifestation)
    circulation_status = CirculationStatus.where(:name => row['circulation_status'].to_s.strip).first || CirculationStatus.where(:name => 'Available On Shelf').first
    shelf = select_item_shelf(row)
    bookstore = Bookstore.where(:name => row['bookstore'].to_s.strip).first
    acquired_at = Time.zone.parse(row['acquired_at']) rescue nil
    use_restriction = UseRestriction.where(:name => row['use_restriction'].to_s.strip).first
    use_restriction_id = use_restriction.id if use_restriction
    item = self.class.import_item(manifestation, {
      :item_identifier => row['item_identifier'],
      :price => row['item_price'],
      :call_number => row['call_number'].to_s.strip,
      :circulation_status => circulation_status,
      :shelf => shelf,
      :acquired_at_string => acquired_at,
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
#    if title[:original_title].blank? and options[:edit_mode] == 'create'
#      return nil
#    end

    if row['isbn'].present?
      if Lisbn.new(row['isbn'].to_s.strip).valid?
        isbn = Lisbn.new(row['isbn'])
      end
    end
    # TODO: 小数点以下の表現
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

    ResourceImportFile.transaction do
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
        work = self.class.import_work(title, creator_patrons, options)
        work.series_statement = series_statement
        work.subjects << subjects
        expression = self.class.import_expression(work, contributor_patrons)
      when 'update'
        expression = manifestation
        work = expression
        work.series_statement = series_statement
        work.subjects = subjects
        work.creators = creator_patrons
        expression.contributors = contributor_patrons
      end

      manifestation = self.class.import_manifestation(expression, publisher_patrons, {
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
    issn = nil
    if row['issn'].present?
      issn = Lisbn.new(row['issn'].to_s)
    end
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
    issn = nil
    if row['issn'].present?
      issn = Lisbn.new(row['issn'].to_s)
    end
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

# == Schema Information
#
# Table name: resource_import_files
#
#  id                           :integer         not null, primary key
#  parent_id                    :integer
#  content_type                 :string(255)
#  size                         :integer
#  file_hash                    :string(255)
#  user_id                      :integer
#  note                         :text
#  imported_at                  :datetime
#  state                        :string(255)
#  resource_import_file_name    :string(255)
#  resource_import_content_type :string(255)
#  resource_import_file_size    :integer
#  resource_import_updated_at   :datetime
#  created_at                   :datetime
#  updated_at                   :datetime
#  edit_mode                    :string(255)
#


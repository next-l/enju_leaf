class ResourceImportFile < ActiveRecord::Base
  include ImportFile
  default_scope :order => 'id DESC'
  scope :not_imported, where(:state => 'pending', :imported_at => nil)
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if configatron.uploaded_file.storage == :s3
    has_attached_file :resource_import, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
      :path => "resource_import_files/:id/:filename"
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
    import
  end

  def import
    self.reload
    num = {:manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0}
    row_num = 2
    rows = self.open_import_file
    field = rows.first
    if [field['isbn'], field['original_title']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify isbn or original_tile in the first line"
    end

    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      import_result = ResourceImportResult.create!(:resource_import_file => self, :body => row.fields.join("\t"))

      item_identifier = row['item_identifier'].to_s.strip
      item = Item.where(:item_identifier => item_identifier).first
      if item
        import_result.item = item
        import_result.save!
        num[:item_found] += 1
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
          isbn = ISBN_Tools.cleanup(row['isbn'])
          manifestation = Manifestation.find_by_isbn(isbn)
        end
      end
      num[:manifestation_found] += 1 if manifestation

      unless manifestation
        manifestation = Manifestation.import_isbn!(isbn) rescue nil
        num[:manifestation_imported] += 1 if manifestation
      end

      unless manifestation
        manifestation = fetch(row)
        num[:manifestation_imported] += 1 if manifestation
      end
      import_result.manifestation = manifestation

      #begin
        if manifestation and item_identifier.present?
          import_result.item = create_item(row, manifestation)
        else
          num[:failed] += 1
        end
      #rescue Exception => e
      #  Rails.logger.info("resource registration failed: column #{row_num}: #{e.message}")
      #end

      import_result.save!
      num[:item_imported] +=1 if import_result.item

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

  def self.import_work(title, patrons, series_statement_id)
    work = Manifestation.new(title)
    if series_statement = SeriesStatement.find(series_statement_id) rescue nil
      work.series_statement = series_statement
    end
    work.creators << patrons
    work
  end

  def self.import_expression(work)
    expression = work
  end

  def self.import_manifestation(expression, patrons, options = {})
    manifestation = expression
    manifestation.update_attributes!(options.merge(:during_import => true))
    manifestation.publishers << patrons
    manifestation
  #rescue ActiveRecord::RecordInvalid
  #  nil
  end

  def self.import_item(manifestation, options)
    options = {:shelf => Shelf.web}.merge(options)
    item = Item.new(options)
    item.manifestation = manifestation
    #if item.save!
      item.patrons << options[:shelf].library.patron
    #end
    item
  end

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

  def self.import
    ResourceImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    logger.info "#{Time.zone.now} importing resources failed!"
  end

  #def import_jpmarc
  #  marc = NKF::nkf('-wc', self.db_file.data)
  #  marc.split("\r\n").each do |record|
  #  end
  #end

  def remove
    rows = self.open_import_file
    field = rows.first
    rows.each do |row|
      item_identifier = row['item_identifier'].to_s.strip
      if item = Item.where(:item_identifier => item_identifier).first
        item.destroy
      end
    end
  end

  def open_import_file
    tempfile = Tempfile.new('patron_import_file')
    if configatron.uploaded_file.storage == :s3
      uploaded_file_path = open(self.resource_import.url).path
    else
      uploaded_file_path = self.resource_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }

    tempfile.open
    if RUBY_VERSION > '1.9'
      file = CSV.open(tempfile, :col_sep => "\t")
      header = file.first
      rows = CSV.open(tempfile, :headers => header, :col_sep => "\t")
    else
      file = FasterCSV.open(tempfile, :col_sep => "\t")
      header = file.first
      rows = FasterCSV.open(tempfile, :headers => header, :col_sep => "\t")
    end
    ResourceImportResult.create(:resource_import_file => self, :body => header.join("\t"))
    tempfile.close
    file.close
    rows
  end

  private
  def import_subject(row)
    subjects = []
    row['subject'].to_s.split(';').each do |s|
      unless subject = Subject.where(:term => s.to_s.strip).first
        # TODO: Subject typeの設定
        subject = Subject.create(:term => s.to_s.strip, :subject_type_id => 1)
      end
      subjects << subject
    end
    subjects
  end

  def create_item(row, manifestation)
    circulation_status = CirculationStatus.where(:name => row['circulation_status'].to_s.strip).first || CirculationStatus.where(:name => 'In Process').first
    shelf = Shelf.where(:name => row['shelf'].to_s.strip).first || Shelf.web
    item = self.class.import_item(manifestation, {
      :item_identifier => row['item_identifier'],
      :price => row['item_price'],
      :call_number => row['call_number'].to_s.strip,
      :circulation_status => circulation_status,
      :shelf => shelf
    })
    item
  end

  def fetch(row)
    shelf = Shelf.where(:name => row['shelf'].to_s.strip).first || Shelf.web
    manifestation = nil

    title = {}
    title[:original_title] = row['original_title']
    title[:title_transcription] = row['title_transcription']
    title[:title_alternative] = row['title_alternative']
    #title[:title_transcription_alternative] = row['title_transcription_alternative']
    return nil if title[:original_title].blank?

    if ISBN_Tools.is_valid?(row['isbn'].to_s.strip)
      isbn = ISBN_Tools.cleanup(row['isbn'])
    end
    # TODO: 小数点以下の表現
    width = NKF.nkf('-eZ1', row['width'].to_s).gsub(/\D/, '').to_i
    height = NKF.nkf('-eZ1', row['height'].to_s).gsub(/\D/, '').to_i
    depth = NKF.nkf('-eZ1', row['depth'].to_s).gsub(/\D/, '').to_i
    end_page = NKF.nkf('-eZ1', row['number_of_pages'].to_s).gsub(/\D/, '').to_i
    language = Language.where(row['language'].to_s.strip).first

    if end_page >= 1
      start_page = 1
    else
      start_page = nil
      end_page = nil
    end

    ResourceImportFile.transaction do
      creators = row['creator'].to_s.split(';')
      publishers = row['publisher'].to_s.split(';')
      creator_patrons = Patron.import_patrons(creators)
      publisher_patrons = Patron.import_patrons(publishers)
      #classification = Classification.first(:conditions => {:category => row['classification'].to_s.strip)
      subjects = import_subject(row)
      series_statement = import_series_statement(row)

      work = self.class.import_work(title, creator_patrons, row['series_statment_id'])
      work.subjects << subjects
      expression = self.class.import_expression(work)

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
        :volume_number_list => row['volume_number_list'],
        :issue_number_list => row['issue_number_list'],
        :serial_number_list => row['serial_number_list'],
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
      })
    end
    manifestation.language = language
    manifestation
  end

  def import_series_statement(row)
    unless series_statement = SeriesStatement.where(:series_statement_identifier => row['series_statement_identifier'].to_s.strip).first
      if row['series_statement_original_title'].to_s.strip.present?
        series_statement = SeriesStatement.create(
          :original_title => row['series_statement_original_title'].to_s.strip,
          :title_transcription => row['series_statement_title_transcription'].to_s.strip,
          :series_statement_identifier => row['series_statement_identifier'].to_s.strip
        )
      end
    end
  end
end

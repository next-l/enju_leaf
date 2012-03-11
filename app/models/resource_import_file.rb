# -*- encoding: utf-8 -*-
class ResourceImportFile < ActiveRecord::Base
  include ImportFile
  default_scope :order => 'id DESC'
  scope :not_imported, where(:state => 'pending')
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if configatron.uploaded_file.storage == :s3
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
    sm_start!
    self.reload
    num = {:manifestation_imported => 0, :item_imported => 0, :manifestation_found => 0, :item_found => 0, :failed => 0}
    row_num = 2
    rows = open_import_file
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
        import_result.manifestation = item.manifestation
        import_result.save!
        num[:item_found] += 1
        next
      end

      if row['manifestation_identifier'].present?
        manifestation = Manifestation.where(:manifestation_identifier => row['manifestation_identifier'].to_s.strip).first
      end

      if row['nbn'].present?
        manifestation = Manifestation.where(:nbn => row['nbn'].to_s.strip).first
      end

      unless manifestation
        if row['isbn'].present?
          isbn = ISBN_Tools.cleanup(row['isbn'])
          m = Manifestation.find_by_isbn(isbn)
          if m
            unless m.series_statement
              manifestation = m
            end
          end
        end
      end
      num[:manifestation_found] += 1 if manifestation

      if row['original_title'].blank?
        unless manifestation
          series_statement = find_series_statement(row)
          begin
            manifestation = Manifestation.import_isbn(isbn)
            manifestation.series_statement = series_statement
            manifestation.save
          rescue EnjuNdl::InvalidIsbn
            manifestation = nil
          rescue EnjuNdl::RecordNotFound
            manifestation = nil
          end
          num[:manifestation_imported] += 1 if manifestation
        end
      end

      unless manifestation
        manifestation = fetch(row)
        num[:manifestation_imported] += 1 if manifestation
      end
      import_result.manifestation = manifestation

      #begin
        if manifestation and item_identifier.present?
          import_result.item = create_item(row, manifestation)
          manifestation.index
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
  rescue
    sm_fail!
  end

  def self.import_work(title, patrons, options = {:edit_mode => 'create'})
    work = Manifestation.new(title)
    work.creators = patrons.uniq unless patrons.empty?
    work
  end

  def self.import_expression(work, patrons, options = {:edit_mode => 'create'})
    expression = work
    expression.contributors = patrons.uniq unless patrons.empty?
    expression
  end

  def self.import_manifestation(expression, patrons, options = {}, edit_options = {:edit_mode => 'create'})
    manifestation = expression
    manifestation.update_attributes!(options.merge(:during_import => true))
    manifestation.publishers = patrons.uniq unless patrons.empty?
    manifestation
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
      publisher = Patron.where(:full_name => record['700']['a']).first
      unless publisher
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
    Rails.logger.info "#{Time.zone.now} importing resources failed!"
  end

  #def import_jpmarc
  #  marc = NKF::nkf('-wc', self.db_file.data)
  #  marc.split("\r\n").each do |record|
  #  end
  #end

  def modify
    sm_start!
    rows = open_import_file
    rows.each do |row|
      item_identifier = row['item_identifier'].to_s.strip
      item = Item.where(:item_identifier => item_identifier).first if item_identifier.present?
      if item
        if item.manifestation
          fetch(row, :edit_mode => 'update')
        end
        shelf = Shelf.where(:name => row['shelf']).first
        circulation_status = CirculationStatus.where(:name => row['circulation_status']).first
        checkout_type = CheckoutType.where(:name => row['checkout_type']).first
        bookstore = Bookstore.where(:name => row['bookstore']).first
        required_role = Role.where(:name => row['required_role']).first

        item.shelf = shelf if shelf
        item.circulation_status = circulation_status if circulation_status
        item.checkout_type = checkout_type if checkout_type
        item.bookstore = bookstore if bookstore
        item.required_role = required_role if required_role
        item.include_supplements = row['include_supplements'] if row['include_supplements']
        item.update_attributes({
          :call_number => row['call_number'],
          :price => row['item_price'],
          :acquired_at => row['acquired_at'],
          :note => row['note']
        })
      end
    end
    sm_complete!
  rescue
    sm_fail!
  end

  def remove
    sm_start!
    rows = open_import_file
    rows.each do |row|
      item_identifier = row['item_identifier'].to_s.strip
      item = Item.where(:item_identifier => item_identifier).first
      if item
        item.destroy if item.deletable?
      end
    end
    sm_complete!
  rescue
    sm_fail!
  end

  private
  def open_import_file
    tempfile = Tempfile.new('patron_import_file')
    if configatron.uploaded_file.storage == :s3
      uploaded_file_path = resource_import.expiring_url(10)
    else
      uploaded_file_path = resource_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    if RUBY_VERSION > '1.9'
      file = CSV.open(tempfile.path, 'r:utf-8', :col_sep => "\t")
      header = file.first
      rows = CSV.open(tempfile.path, 'r:utf-8', :headers => header, :col_sep => "\t")
    else
      file = FasterCSV.open(tempfile.path, 'r:utf-8', :col_sep => "\t")
      header = file.first
      rows = FasterCSV.open(tempfile.path, 'r:utf-8', :headers => header, :col_sep => "\t")
    end
    ResourceImportResult.create(:resource_import_file => self, :body => header.join("\t"))
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

  def create_item(row, manifestation)
    shelf = Shelf.where(:name => row['shelf'].to_s.strip).first || Shelf.web
    bookstore = Bookstore.where(:name => row['bookstore'].to_s.strip).first
    budget_type = BudgetType.where(:name => row['budget_type'].to_s.strip).first
    acquired_at = Time.zone.parse(row['acquired_at']) rescue nil
    item = self.class.import_item(manifestation, {
      :manifestation_id => manifestation.id,
      :item_identifier => row['item_identifier'],
      :price => row['item_price'],
      :call_number => row['call_number'].to_s.strip,
      :shelf => shelf,
      :acquired_at => acquired_at,
      :bookstore => bookstore,
      :budget_type => budget_type
    })
    if defined?(EnjuCirculation)
      circulation_status = CirculationStatus.where(:name => row['circulation_status'].to_s.strip).first || CirculationStatus.where(:name => 'In Process').first
      use_restriction = UseRestriction.where(:name => row['use_restriction'].to_s.strip).first
      use_restriction_id = use_restriction.id if use_restriction
      item.circulation_status = circulation_status
      item.use_restriction_id = use_restriction_id
    end
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
    title[:title_alternative_transcription] = row['title_alternative_transcription'].to_s.strip
    if options[:edit_mode] == 'update'
      title[:original_title] = manifestation.original_title if row['original_title'].to_s.strip.blank?
      title[:title_transcription] = manifestation.title_transcription if row['title_transcription'].to_s.strip.blank?
      title[:title_alternative] = manifestation.title_alternative if row['title_alternative'].to_s.strip.blank?
      title[:title_alternative_transcription] = manifestation.title_alternative_transcription if row['title_alternative_transcription'].to_s.strip.blank?
    end
    #title[:title_transcription_alternative] = row['title_transcription_alternative']
    if title[:original_title].blank? and options[:edit_mode] == 'create'
      return nil
    end

    if ISBN_Tools.is_valid?(row['isbn'].to_s.strip)
      isbn = ISBN_Tools.cleanup(row['isbn'])
    end
    # TODO: 小数点以下の表現
    width = NKF.nkf('-eZ1', row['width'].to_s).gsub(/\D/, '').to_i
    height = NKF.nkf('-eZ1', row['height'].to_s).gsub(/\D/, '').to_i
    depth = NKF.nkf('-eZ1', row['depth'].to_s).gsub(/\D/, '').to_i
    end_page = NKF.nkf('-eZ1', row['number_of_pages'].to_s).gsub(/\D/, '').to_i
    language = Language.where(:name => row['language'].to_s.strip.camelize).first
    language = Language.where(:iso_639_2 => row['language'].to_s.strip.downcase).first unless language
    language = Language.where(:iso_639_1 => row['language'].to_s.strip.downcase).first unless language
    language = Language.where(:name => 'unknown').first unless language

    if end_page >= 1
      start_page = 1
    else
      start_page = nil
      end_page = nil
    end

    creators = row['creator'].to_s.split(';')
    creator_transcriptions = row['creator_transcription'].to_s.split(';')
    creators_list = creators.zip(creator_transcriptions).map{|f,t| {:full_name => f.to_s.strip, :full_name_transcription => t.to_s.strip}}
    contributors = row['contributor'].to_s.split(';')
    contributor_transcriptions = row['contributor_transcription'].to_s.split(';')
    contributors_list = contributors.zip(contributor_transcriptions).map{|f,t| {:full_name => f.to_s.strip, :full_name_transcription => t.to_s.strip}}
    publishers = row['publisher'].to_s.split(';')
    publisher_transcriptions = row['publisher_transcription'].to_s.split(';')
    publishers_list = publishers.zip(publisher_transcriptions).map{|f,t| {:full_name => f.to_s.strip, :full_name_transcription => t.to_s.strip}}
    ResourceImportFile.transaction do
      creator_patrons = Patron.import_patrons(creators_list)
      contributor_patrons = Patron.import_patrons(contributors_list)
      publisher_patrons = Patron.import_patrons(publishers_list)
      #classification = Classification.where(:category => row['classification'].to_s.strip).first
      subjects = import_subject(row) if defined?(EnjuSubject)
      series_statement = import_series_statement(row)
      case options[:edit_mode]
      when 'create'
        work = self.class.import_work(title, creator_patrons, options)
        work.series_statement = series_statement
        if defined?(EnjuSubject)
          work.subjects = subjects.uniq unless subjects.empty?
        end
        expression = self.class.import_expression(work, contributor_patrons)
      when 'update'
        expression = manifestation
        work = expression
        work.series_statement = series_statement
        work.creators = creator_patrons.uniq unless creator_patrons.empty?
        expression.contributors = contributor_patrons.uniq unless contributor_patrons.empty?
        if defined?(EnjuSubject)
          work.subjects = subjects.uniq unless subjects.empty?
        end
      end
      if row['volume_number'].present?
        volume_number = row['volume_number'].to_s.tr('０-９', '0-9').to_i
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
        :ndc => row['ndc'],
        :pub_date => row['pub_date'],
        :volume_number_string => row['volume_number_string'].to_s.split('　').first.try(:tr, '０-９', '0-9'),
        :issue_number_string => row['issue_number_string'],
        :serial_number => row['serial_number'],
        :edition_string => row['edition_string'],
        :width => width,
        :depth => depth,
        :height => height,
        :price => row['manifestation_price'],
        :description => row['description'],
        #:description_transcription => row['description_transcription'],
        :note => row['note'],
        :series_statement => series_statement,
        :start_page => start_page,
        :end_page => end_page,
        :access_address => row['access_addres'],
        :manifestation_identifier => row['manifestation_identifier']
      },
      {
        :edit_mode => options[:edit_mode]
      })
      manifestation.volume_number = volume_number
      manifestation.required_role = Role.where(:name => row['required_role_name'].to_s.strip.camelize).first || Role.find('Guest')
      manifestation.language = language
      manifestation.save!
    end
    manifestation
  end

  def import_series_statement(row)
    issn = ISBN_Tools.cleanup(row['issn'].to_s)
    series_statement = find_series_statement(row)
    unless series_statement
      if row['series_title'].to_s.strip.present?
        title = row['series_title'].to_s.strip.split(';')
        title_transcription = row['series_title_transcription'].to_s.strip.split(';')
        series_statement = SeriesStatement.new(
          :original_title => title[0],
          :title_transcription => title_transcription[0],
          :series_statement_identifier => row['series_statement_identifier'].to_s.strip.split(';').first,
          :title_subseries => "#{title[1]} #{title[2]}",
          :title_subseries_transcription => "#{title_transcription[1]} #{title_transcription[2]}"
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
            series_statement.root_manifestation.creators << creator_patrons
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
    issn = ISBN_Tools.cleanup(row['issn'].to_s)
    series_statement_identifier = row['series_statement_identifier'].to_s.strip
    series_statement = SeriesStatement.where(:issn => issn).first if issn.present?
    unless series_statement
      series_statement = SeriesStatement.where(:series_statement_identifier => series_statement_identifier).first if series_statement_identifier.present?
    end
    series_statement = SeriesStatement.where(:original_title => row['series_statement_original_title'].to_s.strip).first unless series_statement
    series_statement
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


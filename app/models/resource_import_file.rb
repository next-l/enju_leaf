class ResourceImportFile < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ResourceImportFileTransition,
    initial_state: ResourceImportFileStateMachine.initial_state
  ]
  include ImportFile
  default_scope { order('resource_import_files.id DESC') }
  scope :not_imported, -> { in_state(:pending) }
  scope :stucked, -> { in_state(:pending).where('resource_import_files.created_at < ?', 1.hour.ago) }

  if ENV['ENJU_STORAGE'] == 's3'
    has_attached_file :resource_import, storage: :s3,
      s3_credentials: {
        access_key: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_NAME'],
        s3_host_name: ENV['S3_HOST_NAME'],
        s3_region: ENV['S3_REGION']
      },
      s3_permissions: :private
  else
    has_attached_file :resource_import,
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :resource_import, content_type: [
    'text/csv',
    'text/plain',
    'text/tab-separated-values',
    'application/octet-stream',
    'application/vnd.ms-excel'
  ]
  validates_attachment_presence :resource_import
  validates :default_shelf_id, presence: true, if: proc{|model| model.edit_mode == 'create'}
  belongs_to :user
  belongs_to :default_shelf, class_name: 'Shelf', optional: true
  has_many :resource_import_results, dependent: :destroy
  has_many :resource_import_file_transitions, autosave: false, dependent: :destroy

  attr_accessor :mode, :library_id

  def state_machine
    ResourceImportFileStateMachine.new(self, transition_class: ResourceImportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def import_start
    case edit_mode
    when 'create'
      import
    when 'update'
      modify
    when 'destroy'
      remove
    when 'update_relationship'
      update_relationship
    else
      import
    end
  end

  def import
    transition_to!(:started)
    num = {
      manifestation_imported: 0,
      item_imported: 0,
      manifestation_found: 0,
      item_found: 0,
      failed: 0
    }
    rows = open_import_file(create_import_temp_file(resource_import))
    rows.shift
    #if [field['manifestation_id'], field['manifestation_identifier'], field['isbn'], field['original_title']].reject{|f|
    #  f.to_s.strip == ''
    #}.empty?
    #  raise "You should specify isbn or original_title in the first line"
    #end
    row_num = 1

    ResourceImportResult.create!(resource_import_file_id: id, body: (%w( imported_manifestation_id imported_item_id ) + rows.headers).join("\t"))
    rows.each do |row|
      row_num += 1
      import_result = ResourceImportResult.new(resource_import_file_id: id)
      if row['dummy'].to_s.strip.present?
        import_result.error_message = "line #{row_num}: #{I18n.t('import.dummy')}"
        import_result.body = ([nil, nil] + row.fields).join("\t")
        import_result.save!
        next
      end

      item_identifier = row['item_identifier'].to_s.strip
      item = Item.find_by(item_identifier: item_identifier)
      if item
        import_result.item = item
        import_result.manifestation = item.manifestation
        import_result.error_message = "line #{row_num}: #{I18n.t('import.item_found')}"
        import_result.body = ([item.manifestation.id, item.id] + row.fields).join("\t")
        import_result.save!
        num[:item_found] += 1
        next
      end

      if row['manifestation_identifier'].present?
        manifestation = Manifestation.find_by(manifestation_identifier: row['manifestation_identifier'].to_s.strip)
      end

      unless manifestation
        if row['manifestation_id'].present?
          manifestation = Manifestation.find_by(id: row['manifestation_id'].to_s.strip)
        end
      end

      unless manifestation
        if row['iss_itemno'].present?
          iss_itemno = URI.parse(row['iss_itemno']).path.gsub(/^\//, "")
          identifier_type_iss_itemno = IdentifierType.find_or_create_by!(name: 'iss_itemno')
          manifestation = Identifier.find_by(body: iss_itemno, identifier_type_id: identifier_type_iss_itemno.id).try(:manifestation)
        end
      end

      unless manifestation
        if row['doi'].present?
          doi = URI.parse(row['doi'].downcase).path.gsub(/^\//, "")
          identifier_type_doi = IdentifierType.find_or_create_by!(name: 'doi')
          manifestation = Identifier.find_by(body: doi, identifier_type_id: identifier_type_doi.id).try(:manifestation)
        end
      end

      unless manifestation
        if row['jpno'].present?
          jpno = row['jpno'].to_s.strip
          identifier_type_jpno = IdentifierType.find_or_create_by!(name: 'jpno')
          manifestation = Identifier.find_by(body: jpno, identifier_type_id: identifier_type_jpno.id).try(:manifestation)
        end
      end

      unless manifestation
        if row['ncid'].present?
          ncid = row['ncid'].to_s.strip
          identifier_type_ncid = IdentifierType.find_or_create_by!(name: 'ncid')
          manifestation = Identifier.find_by(body: ncid, identifier_type_id: identifier_type_ncid.id).try(:manifestation)
        end
      end

      unless manifestation
        if row['lccn'].present?
          lccn = row['lccn'].to_s.strip
          identifier_type_lccn = IdentifierType.find_or_create_by!(name: 'lccn')
          manifestation = Identifier.find_by(body: lccn, identifier_type_id: identifier_type_lccn.id).try(:manifestation)
        end
      end

      unless manifestation
        if row['isbn'].present?
          if StdNum::ISBN.valid?(row['isbn'])
            isbn = StdNum::ISBN.normalize(row['isbn'])
            identifier_type_isbn = IdentifierType.find_or_create_by!(name: 'isbn')
            m = Identifier.find_by(body: isbn, identifier_type_id: identifier_type_isbn.id).try(:manifestation)
            if m
              if m.series_statements.exists?
                manifestation = m
              end
            end
          else
            import_result.error_message = "line #{row_num}: #{I18n.t('import.isbn_invalid')}"
          end
        end
      end

      if manifestation
        import_result.error_message = "line #{row_num}: #{I18n.t('import.manifestation_found')}"
        num[:manifestation_found] += 1
      end

      if row['original_title'].blank?
        unless manifestation
          begin
            manifestation = Manifestation.import_isbn(isbn) if isbn
            if manifestation
              num[:manifestation_imported] += 1
            end
          rescue EnjuNdl::InvalidIsbn
            manifestation = nil
            import_result.error_message = "line #{row_num}: #{I18n.t('import.isbn_invalid')}"
          rescue EnjuNdl::RecordNotFound
            manifestation = nil
            import_result.error_message = "line #{row_num}: #{I18n.t('import.isbn_record_not_found')}"
          end
        end
        if manifestation.nil? && row['ndl_bib_id']
          manifestation = Manifestation.import_ndl_bib_id(row['ndl_bib_id'])
          if manifestation
            num[:manifestation_imported] += 1
          end
        end
      end

      unless manifestation
        manifestation = fetch(row)
        num[:manifestation_imported] += 1 if manifestation
      end
      import_result.manifestation = manifestation

      if manifestation
        ResourceImportFile.import_manifestation_custom_value(row, manifestation).each do |value|
          value.update!(manifestation: manifestation)
        end

        item = nil
        if item_identifier.present? || row['shelf'].present? || row['call_number'].present?
          item = create_item(row, manifestation)
        else
          if manifestation.fulltext_content?
            item = create_item(row, manifestation)
            item.circulation_status = CirculationStatus.find_by(name: 'Available On Shelf')
            begin
              item.acquired_at = Time.zone.parse(row['acquired_at'].to_s.strip)
            rescue ArgumentError
            end
          end
          num[:failed] += 1
        end

        if item
          ResourceImportFile.import_item_custom_value(row, item).each do |value|
            value.update!(item: item)
          end

          import_result.item = item
        end
      else
        num[:failed] += 1
      end

      import_result.body = ([manifestation.try(:id), item.try(:id)] + row.fields).join("\t")
      import_result.save!
      num[:item_imported] += 1 if import_result.item
    end

    Sunspot.commit
    rows.close
    transition_to!(:completed)
    mailer = ResourceImportMailer.completed(self)
    send_message(mailer)
    Rails.cache.write("manifestation_search_total", Manifestation.search.total)
    num
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    mailer = ResourceImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def self.import_work(title, agents, options = {edit_mode: 'create'})
    work = Manifestation.new(title)
    work.save
    work.creators = agents.uniq unless agents.empty?
    work
  end

  def self.import_expression(work, agents, options = {edit_mode: 'create'})
    expression = work
    expression.save
    expression.contributors = agents.uniq unless agents.empty?
    expression
  end

  def self.import_manifestation(expression, agents, options = {}, edit_options = {edit_mode: 'create'})
    manifestation = expression
    manifestation.during_import = true
    manifestation.reload
    manifestation.update!(options)
    manifestation.publishers = agents.uniq unless agents.empty?
    manifestation.reload
    manifestation
  end

  def import_marc(marc_type)
    file = File.open(resource_import.path)
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
    reader.each do |record|
      manifestation = Manifestation.new(original_title: expression.original_title)
      manifestation.carrier_type = CarrierType.find(1)
      manifestation.frequency = Frequency.find(1)
      manifestation.language = Language.find(1)
      manifestation.save

      full_name = record['700']['a']
      publisher = Agent.find_by(full_name: record['700']['a'])
      unless publisher
        publisher = Agent.new(full_name: full_name)
        publisher.save
      end
      manifestation.publishers << publisher
    end
  end

  def self.import
    ResourceImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue StandardError
    Rails.logger.info "#{Time.zone.now} importing resources failed!"
  end

  #def import_jpmarc
  #  marc = NKF::nkf('-wc', self.db_file.data)
  #  marc.split("\r\n").each do |record|
  #  end
  #end

  def modify
    transition_to!(:started)
    rows = open_import_file(create_import_temp_file(resource_import))
    rows.shift
    row_num = 1

    ResourceImportResult.create!(resource_import_file_id: id, body: rows.headers.join("\t"))
    rows.each do |row|
      row_num += 1
      import_result = ResourceImportResult.create!(resource_import_file_id: id, body: row.fields.join("\t"))
      item = Item.find_by(item_identifier: row['item_identifier'].to_s.strip) if row['item_identifier'].to_s.strip.present?
      unless item
        item = Item.find_by(id: row['item_id'].to_s.strip) if row['item_id'].to_s.strip.present?
      end

      if item
        if item.manifestation
          fetch(row, edit_mode: 'update')
          item = update_item(item, row)
        end

        ResourceImportFile.import_item_custom_value(row, item).each do |value|
          value.update!(item: item)
        end
        ResourceImportFile.import_manifestation_custom_value(row, item.manifestation).each do |value|
          value.update!(manifestation: item.manifestation)
        end

        item.manifestation.reload
        item.save!
        import_result.item = item
      else
        manifestation_identifier = row['manifestation_identifier'].to_s.strip
        manifestation = Manifestation.find_by(manifestation_identifier: manifestation_identifier) if manifestation_identifier.present?
        manifestation ||= Manifestation.find_by(id: row['manifestation_id'])
        if manifestation
          fetch(row, edit_mode: 'update')
          ResourceImportFile.import_manifestation_custom_value(row, manifestation).each do |value|
            value.update!(manifestation: manifestation)
          end
          import_result.manifestation = manifestation
        end
      end
      import_result.save!
    end
    transition_to!(:completed)
    mailer = ResourceImportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    mailer = ResourceImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def remove
    transition_to!(:started)
    rows = open_import_file(create_import_temp_file(resource_import))
    rows.shift
    row_num = 1

    rows.each do |row|
      row_num += 1
      item = Item.find_by(item_identifier: row['item_identifier'].to_s.strip) if row['item_identifier'].to_s.strip.present?
      unless item
        item = Item.find_by(id: row['item_id'].to_s.strip) if row['item_id'].to_s.strip.present?
      end

      if item
        item.destroy if item.removable?
      end
    end
    transition_to!(:completed)
    mailer = ResourceImportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    mailer = ResourceImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def update_relationship
    transition_to!(:started)
    rows = open_import_file(create_import_temp_file(resource_import))
    rows.shift
    row_num = 1

    rows.each do |row|
      item = Item.find_by(item_identifier: row['item_identifier'].to_s.strip) if row['item_identifier'].to_s.strip.present?
      unless item
        item = Item.find_by(id: row['item_id'].to_s.strip) if row['item_id'].to_s.strip.present?
      end

      manifestation_identifier = row['manifestation_identifier'].to_s.strip
      manifestation = Manifestation.find_by(manifestation_identifier: manifestation_identifier)
      manifestation ||= Manifestation.find_by(id: row['manifestation_id'].to_s.strip)

      if item && manifestation
        item.manifestation = manifestation
        item.save!
      end

      import_result = ResourceImportResult.create!(resource_import_file_id: id, body: row.fields.join("\t"))
      import_result.item = item
      import_result.manifestation = manifestation
      import_result.save!
      row_num += 1
    end
    transition_to!(:completed)
    mailer = ResourceImportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    mailer = ResourceImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  private

  def open_import_file(tempfile)
    file = CSV.open(tempfile, col_sep: "\t")
    header_columns = %w(
      original_title manifestation_identifier item_identifier shelf note
      title_transcription title_alternative title_alternative_transcription
      serial manifestation_id publication_place carrier_type
      series_statement_identifier series_original_title series_creator_string
      series_title_transcription series_volume_number_string
      series_title_subseries series_title_subseries_transcription
      creator creator_transcription publisher
      publisher_transcription pub_date creator creator_transcription
      contributor contributor_transcription abstract description access_address
      volume_number volume_number_string issue_number issue_number_string
      edition edition_string serial_number isbn issn manifestation_price
      width height depth number_of_pages jpno lccn budget_type bookstore
      language fulltext_content manifestation_required_role doi content_type
      frequency extent start_page end_page dimensions manifestation_memo
      ncid
      ndl_bib_id
      statement_of_responsibility acquired_at call_number circulation_status
      binding_item_identifier binding_call_number binded_at item_price
      use_restriction include_supplements item_note item_url item_memo
      item_required_role
      dummy
    )
    header_columns += ManifestationCustomProperty.order(:position).pluck(:name).map{|c| "manifestation:#{c}"}
    header_columns += ItemCustomProperty.order(:position).pluck(:name).map{|c| "item:#{c}"}

    if defined?(EnjuSubject)
      header_columns += ClassificationType.order(:position).pluck(:name).map{|c| "classification:#{c}"}
      header_columns += SubjectHeadingType.order(:position).pluck(:name).map{|s| "subject:#{s}"}
    end
    header = file.first
    ignored_columns = header - header_columns
    unless ignored_columns.empty?
      self.error_message = I18n.t('import.following_column_were_ignored', column: ignored_columns.join(', '))
      save!
    end
    rows = CSV.open(tempfile, headers: header, col_sep: "\t")
    #ResourceImportResult.create!(resource_import_file_id: id, body: header.join("\t"))
    tempfile.close(true)
    file.close
    rows
  end

  def import_subject(row)
    subjects = []
    SubjectHeadingType.order(:position).pluck(:name).map{|s| "subject:#{s}"}.each do |column_name|
      type = column_name.split(':').last
      subject_list = row[column_name].to_s.split('//')
      subject_list.map{|value|
        subject_heading_type = SubjectHeadingType.find_by(name: type)
        next unless subject_heading_type

        subject = Subject.new(term: value)
        subject.subject_heading_type = subject_heading_type
        # TODO: Subject typeの設定
        subject.subject_type = SubjectType.find_by(name: 'concept')
        subject.save!
        subjects << subject
      }
    end
    subjects
  end

  def import_classification(row)
    classifications = []
    ClassificationType.order(:position).pluck(:name).map{|c| "classification:#{c}"}.each do |column_name|
      type = column_name.split(':').last
      classification_list = row[column_name].to_s.split('//')
      classification_list.map{|value|
        classification_type = ClassificationType.find_by(name: type)
        next unless classification_type

        classification = Classification.new(category: value)
        classification.classification_type = classification_type
        classification.save!
        classifications << classification
      }
    end
    classifications
  end

  def create_item(row, manifestation)
    shelf = Shelf.find_by(name: row['shelf'].to_s.strip)
    shelf ||= default_shelf || Shelf.web
    bookstore = Bookstore.find_by(name: row['bookstore'].to_s.strip)
    budget_type = BudgetType.find_by(name: row['budget_type'].to_s.strip)
    acquired_at = Time.zone.parse(row['acquired_at']) rescue nil
    binded_at = Time.zone.parse(row['binded_at']) rescue nil
    item = Item.new(
      manifestation_id: manifestation.id,
      item_identifier: row['item_identifier'],
      price: row['item_price'],
      call_number: row['call_number'].to_s.strip,
      acquired_at: acquired_at,
      binding_item_identifier: row['binding_item_identifier'],
      binding_call_number: row['binding_call_number'],
      binded_at: binded_at,
      url: row['item_url'],
      note: row['item_note'].try(:gsub, /\\n/, "\n"),
      memo: row['item_memo'].try(:gsub, /\\n/, "\n")
    )
    manifestation.items << item
    if defined?(EnjuCirculation)
      circulation_status = CirculationStatus.find_by(name: row['circulation_status'].to_s.strip) || CirculationStatus.find_by(name: 'In Process')
      item.circulation_status = circulation_status
      use_restriction = UseRestriction.find_by(name: row['use_restriction'].to_s.strip)
      use_restriction ||= UseRestriction.find_by(name: 'Not For Loan')
      item.use_restriction = use_restriction
    end
    item.bookstore = bookstore
    item.budget_type = budget_type
    item.shelf = shelf
    item.shelf = Shelf.web unless item.shelf

    if %w(t true).include?(row['include_supplements'].to_s.downcase.strip)
      item.include_supplements = true
    end
    item.save!
    item
  end

  def update_item(item, row)
    shelf = Shelf.find_by(name: row['shelf'].to_s.strip)
    bookstore = Bookstore.find_by(name: row['bookstore'])
    required_role = Role.find_by(name: row['item_required_role'])

    item.shelf = shelf if shelf
    item.bookstore = bookstore if bookstore
    item.required_role = required_role if required_role

    acquired_at = Time.zone.parse(row['acquired_at']) rescue nil
    binded_at = Time.zone.parse(row['binded_at']) rescue nil
    item.acquired_at = acquired_at if acquired_at
    item.binded_at = binded_at if binded_at

    if defined?(EnjuCirculation)
      circulation_status = CirculationStatus.find_by(name: row['circulation_status'])
      checkout_type = CheckoutType.find_by(name: row['checkout_type'])
      use_restriction = UseRestriction.find_by(name: row['use_restriction'].to_s.strip)
      item.circulation_status = circulation_status if circulation_status
      item.checkout_type = checkout_type if checkout_type
      item.use_restriction = use_restriction if use_restriction
    end

    item_columns = %w(
      call_number
      binding_item_identifier binding_call_number binded_at
    )
    item_columns.each do |column|
      if row[column].present?
        item.assign_attributes(:"#{column}" => row[column])
      end
    end

    item.price = row['item_price'] if row['item_price'].present?
    item.note = row['item_note'].try(:gsub, /\\n/, "\n") if row['item_note'].present?
    item.memo = row['item_memo'].try(:gsub, /\\n/, "\n") if row['item_memo'].present?
    item.url = row['item_url'] if row['item_url'].present?

    if row['include_supplements']
      if %w(t true).include?(row['include_supplements'].downcase.strip)
        item.include_supplements = true
      elsif item.include_supplements
        item.include_supplements = false
end
    end

    item
  end

  def fetch(row, options = {edit_mode: 'create'})
    manifestation = nil
    item = nil

    if options[:edit_mode] == 'update'
      if row['item_identifier'].to_s.strip.present?
        item = Item.find_by(item_identifier: row['item_identifier'].to_s.strip)
      end
      if row['item_id'].to_s.strip.present?
        item = Item.find_by(id: row['item_id'].to_s.strip)
      end

      manifestation = item.manifestation if item

      unless manifestation
        manifestation_identifier = row['manifestation_identifier'].to_s.strip
        manifestation = Manifestation.find_by(manifestation_identifier: manifestation_identifier) if manifestation_identifier
        manifestation ||= Manifestation.find_by(id: row['manifestation_id'])
      end
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
    if title[:original_title].blank? && options[:edit_mode] == 'create'
      return nil
    end

    # TODO: 小数点以下の表現
    language = Language.find_by(name: row['language'].to_s.strip.camelize) || Language.find_by(iso_639_2: row['language'].to_s.strip.downcase) || Language.find_by(iso_639_1: row['language'].to_s.strip.downcase)

    carrier_type = CarrierType.find_by(name: row['carrier_type'].to_s.strip)
    content_type = ContentType.find_by(name: row['content_type'].to_s.strip)
    frequency = Frequency.find_by(name: row['frequency'].to_s.strip)

    fulltext_content = serial = nil
    if %w(t true).include?(row['fulltext_content'].to_s.downcase.strip)
      fulltext_content = true
    end

    if %w(t true).include?(row['serial'].to_s.downcase.strip)
      serial = true
    end

    creators = row['creator'].to_s.split('//')
    creator_transcriptions = row['creator_transcription'].to_s.split('//')
    creators_list = creators.zip(creator_transcriptions).map{|f, t| {full_name: f.to_s.strip, full_name_transcription: t.to_s.strip}}
    contributors = row['contributor'].to_s.split('//')
    contributor_transcriptions = row['contributor_transcription'].to_s.split('//')
    contributors_list = contributors.zip(contributor_transcriptions).map{|f, t| {full_name: f.to_s.strip, full_name_transcription: t.to_s.strip}}
    publishers = row['publisher'].to_s.split('//')
    publisher_transcriptions = row['publisher_transcription'].to_s.split('//')
    publishers_list = publishers.zip(publisher_transcriptions).map{|f, t| {full_name: f.to_s.strip, full_name_transcription: t.to_s.strip}}
    ResourceImportFile.transaction do
      creator_agents = Agent.import_agents(creators_list)
      contributor_agents = Agent.import_agents(contributors_list)
      publisher_agents = Agent.import_agents(publishers_list)
      subjects = import_subject(row) if defined?(EnjuSubject)
      case options[:edit_mode]
      when 'create'
        work = self.class.import_work(title, creator_agents, options)
        if defined?(EnjuSubject)
          work.subjects = subjects.uniq unless subjects.empty?
        end
        expression = self.class.import_expression(work, contributor_agents)
      when 'update'
        expression = manifestation
        work = expression
        work.creators = creator_agents.uniq unless creator_agents.empty?
        expression.contributors = contributor_agents.uniq unless contributor_agents.empty?
        if defined?(EnjuSubject)
          work.subjects = subjects.uniq unless subjects.empty?
        end
      end

      attributes = {
        original_title: title[:original_title],
        title_transcription: title[:title_transcription],
        title_alternative: title[:title_alternative],
        title_alternative_transcription: title[:title_alternative_transcription],
        pub_date: row['pub_date'],
        volume_number: row['volume_number'],
        volume_number_string: row['volume_number_string'],
        issue_number: row['issue_number'],
        issue_number_string: row['issue_number_string'],
        serial_number: row['serial_number'],
        edition: row['edition'],
        edition_string: row['edition_string'],
        width: row['width'],
        depth: row['depth'],
        height: row['height'],
        price: row['manifestation_price'],
        abstract: row['abstract'].try(:gsub, /\\n/, "\n"),
        description: row['description'].try(:gsub, /\\n/, "\n"),
        #:description_transcription => row['description_transcription'],
        note: row['note'].try(:gsub, /\\n/, "\n"),
        memo: row['manifestation_memo'].try(:gsub, /\\n/, "\n"),
        statement_of_responsibility: row['statement_of_responsibility'],
        access_address: row['access_address'],
        manifestation_identifier: row['manifestation_identifier'],
        publication_place: row['publication_place'],
        extent: row['extent'],
        dimensions: row['dimensions'],
        start_page: row['start_page'],
        end_page: row['end_page'],
      }.delete_if{|_key, value| value.nil?}

      manifestation = self.class.import_manifestation(expression, publisher_agents, attributes,
      {
        edit_mode: options[:edit_mode]
      })

      required_role = Role.find_by(name: row['manifestation_required_role'].to_s.strip.camelize)
      if required_role && row['manifestation_required_role'].present?
        manifestation.required_role = required_role
      else
        manifestation.required_role = Role.find_by(name: 'Guest') unless manifestation.required_role
      end

      if language && row['language'].present?
        manifestation.language = language
      else
        manifestation.language = Language.find_by(name: 'unknown') unless manifestation.language
      end

      manifestation.carrier_type = carrier_type if carrier_type
      manifestation.manifestation_content_type = content_type if content_type
      manifestation.frequency = frequency if frequency
      #manifestation.start_page = row[:start_page].to_i if row[:start_page]
      #manifestation.end_page = row[:end_page].to_i if row[:end_page]
      manifestation.serial = serial if row['serial']
      manifestation.fulltext_content = fulltext_content if row['fulltext_content']

      if row['series_original_title'].to_s.strip.present?
        Manifestation.transaction do
          if manifestation.series_statements.exists?
            manifestation.series_statements.delete_all
          end
          if row['series_original_title']
            series_statement = SeriesStatement.new(
              original_title: row['series_original_title'],
              title_transcription: row['series_title_transcription'],
              title_subseries: row['series_title_subseries'],
              title_subseries_transcription: row['series_title_subseries_transcription'],
              volume_number_string: row['series_volume_number_string'],
              creator_string: row['series_creator_string']
            )
            series_statement.manifestation = manifestation
            series_statement.save!
          end
        end
      end

      identifiers = set_identifier(row)

      if manifestation.save
        Manifestation.transaction do
          if options[:edit_mode] == 'update'
            unless identifiers.empty?
              identifiers.each do |v|
                v.manifestation = manifestation
                v.save
              end
            end
          else
            manifestation.identifiers << identifiers
          end
        end

        if defined?(EnjuSubject)
          classifications = import_classification(row)
          if classifications.present?
            manifestation.classifications = classifications
          end
        end
      end

      manifestation.save!

      if options[:edit_mode] == 'create'
        manifestation.set_agent_role_type(creators_list)
        manifestation.set_agent_role_type(contributors_list, scope: :contributor)
        manifestation.set_agent_role_type(publishers_list, scope: :publisher)
      end
    end

    manifestation
  end

  def set_identifier(row)
    identifiers = []
    %w(isbn issn doi jpno ncid lccn iss_itemno).each do |id_type|
      next unless row[id_type.to_s].present?

      row[id_type].split(/\/\//).each do |identifier_s|
        import_id = Identifier.new(body: identifier_s)
        identifier_type = IdentifierType.find_or_create_by!(name: id_type)
        import_id.identifier_type = identifier_type
        identifiers << import_id if import_id.valid?
      end
    end
    identifiers
  end

  def self.import_manifestation_custom_value(row, manifestation)
    values = []
    ManifestationCustomProperty.order(:position).pluck(:name).map{|c| "manifestation:#{c}"}.each do |column_name|
      value = nil
      property = column_name.split(':').last
      next if row[column_name].blank?

      if manifestation
        value = manifestation.manifestation_custom_values.find_by(manifestation_custom_property: property)
      end

      if value
        value.value = row[column_name]
      else
        value = ManifestationCustomValue.new(
          manifestation_custom_property: ManifestationCustomProperty.find_by(name: property),
          value: row[column_name]
        )
      end
      values << value
    end
    values
  end

  def self.import_item_custom_value(row, item)
    values = []
    ItemCustomProperty.order(:position).pluck(:name).map{|c| "item:#{c}"}.each do |column_name|
      value = nil
      property = column_name.split(':').last
      next if row[column_name].blank?

      value = item.item_custom_values.find_by(item_custom_property: property) if item

      if value
        value.value = row[column_name]
      else
        value = ItemCustomValue.new(
          item_custom_property: ItemCustomProperty.find_by(name: property),
          value: row[column_name]
        )
      end
      values << value
    end
    values
  end
end

# == Schema Information
#
# Table name: resource_import_files
#
#  id                           :bigint           not null, primary key
#  parent_id                    :integer
#  content_type                 :string
#  size                         :integer
#  user_id                      :integer
#  note                         :text
#  executed_at                  :datetime
#  resource_import_file_name    :string
#  resource_import_content_type :string
#  resource_import_file_size    :integer
#  resource_import_updated_at   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  edit_mode                    :string
#  resource_import_fingerprint  :string
#  error_message                :text
#  user_encoding                :string
#  default_shelf_id             :integer
#

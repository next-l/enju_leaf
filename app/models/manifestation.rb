class Manifestation < ApplicationRecord
  include EnjuCirculation::EnjuManifestation
  include EnjuSubject::EnjuManifestation
  include EnjuNdl::EnjuManifestation
  include EnjuNii::EnjuManifestation
  include EnjuLoc::EnjuManifestation
  include EnjuManifestationViewer::EnjuManifestation
  include EnjuBookmark::EnjuManifestation
  include EnjuOai::OaiModel

  has_many :creates, -> { order('creates.position') }, dependent: :destroy, foreign_key: 'work_id', inverse_of: :work
  has_many :creators, through: :creates, source: :agent
  has_many :realizes, -> { order('realizes.position') }, dependent: :destroy, foreign_key: 'expression_id', inverse_of: :expression
  has_many :contributors, through: :realizes, source: :agent
  has_many :produces, -> { order('produces.position') }, dependent: :destroy, foreign_key: 'manifestation_id', inverse_of: :manifestation
  has_many :publishers, through: :produces, source: :agent
  has_many :items, dependent: :destroy
  has_many :children, foreign_key: 'parent_id', class_name: 'ManifestationRelationship', dependent: :destroy, inverse_of: :parent
  has_many :parents, foreign_key: 'child_id', class_name: 'ManifestationRelationship', dependent: :destroy, inverse_of: :child
  has_many :derived_manifestations, through: :children, source: :child
  has_many :original_manifestations, through: :parents, source: :parent
  has_many :picture_files, as: :picture_attachable, dependent: :destroy
  belongs_to :language
  belongs_to :carrier_type
  belongs_to :manifestation_content_type, class_name: 'ContentType', foreign_key: 'content_type_id', inverse_of: :manifestations
  has_many :series_statements, dependent: :destroy
  belongs_to :frequency
  belongs_to :required_role, class_name: 'Role'
  has_one :resource_import_result
  has_many :identifiers, dependent: :destroy
  has_many :manifestation_custom_values, -> { joins(:manifestation_custom_property).order(:position) }, inverse_of: :manifestation, dependent: :destroy
  has_one :periodical_record, class_name: 'Periodical', dependent: :destroy
  has_one :periodical_and_manifestation, dependent: :destroy
  has_one :periodical, through: :periodical_and_manifestation, dependent: :destroy
  has_one :doi_record, dependent: :destroy
  has_one :jpno_record, dependent: :destroy
  has_one :ncid_record, dependent: :destroy

  accepts_nested_attributes_for :creators, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :contributors, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :publishers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :series_statements, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :identifiers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :manifestation_custom_values, reject_if: :all_blank
  accepts_nested_attributes_for :doi_record, reject_if: :all_blank
  accepts_nested_attributes_for :jpno_record, reject_if: :all_blank
  accepts_nested_attributes_for :ncid_record, reject_if: :all_blank

  searchable do
    text :title, default_boost: 2 do
      titles
    end
    [:fulltext, :note, :creator, :contributor, :publisher, :abstract, :description, :statement_of_responsibility].each do |field|
      text field do
        if series_master?
          derived_manifestations.map{|c| c.send(field) }.flatten.compact
        else
          self.send(field)
        end
      end
    end
    text :item_identifier do
      if series_master?
        root_series_statement.root_manifestation.items.pluck(:item_identifier, :binding_item_identifier).flatten.compact
      else
        items.pluck(:item_identifier, :binding_item_identifier).flatten.compact
      end
    end
    string :call_number, multiple: true do
      items.pluck(:call_number)
    end
    string :title, multiple: true
    # text フィールドだと区切りのない文字列の index が上手く作成
    #できなかったので。 downcase することにした。
    #他の string 項目も同様の問題があるので、必要な項目は同様の処置が必要。
    string :connect_title do
      title.join('').gsub(/\s/, '').downcase
    end
    string :connect_creator do
      creator.join('').gsub(/\s/, '').downcase
    end
    string :connect_publisher do
      publisher.join('').gsub(/\s/, '').downcase
    end
    string :isbn, multiple: true do
      isbn_characters
    end
    string :issn, multiple: true do
      if series_statements.exists?
        [identifier_contents(:issn), (series_statements.map{|s| s.manifestation.identifier_contents(:issn)})].flatten.uniq.compact
      else
        identifier_contents(:issn)
      end
    end
    string :lccn, multiple: true do
      identifier_contents(:lccn)
    end
    string :jpno, multiple: true do
      jpno_record&.body
    end
    string :carrier_type do
      carrier_type.name
    end
    string :library, multiple: true do
      if series_master?
        root_series_statement.root_manifestation.items.map{|i| i.shelf.library.name}.flatten.uniq
      else
        items.map{|i| i.shelf.library.name}
      end
    end
    string :language do
      language&.name
    end
    string :item_identifier, multiple: true do
      if series_master?
        root_series_statement.root_manifestation.items.pluck(:item_identifier, :binding_item_identifier).flatten.compact
      else
        items.pluck(:item_identifier, :binding_item_identifier).flatten.compact
      end
    end
    string :shelf, multiple: true do
      items.collect{|i| "#{i.shelf.library.name}_#{i.shelf.name}"}
    end
    time :created_at
    time :updated_at
    time :pub_date, multiple: true do
      if series_master?
        root_series_statement.root_manifestation.pub_dates
      else
        pub_dates
      end
    end
    time :date_of_publication
    integer :pub_year do
      date_of_publication&.year
    end
    integer :creator_ids, multiple: true
    integer :contributor_ids, multiple: true
    integer :publisher_ids, multiple: true
    integer :item_ids, multiple: true
    integer :original_manifestation_ids, multiple: true
    integer :parent_ids, multiple: true do
      original_manifestations.pluck(:id)
    end
    integer :required_role_id
    integer :height
    integer :width
    integer :depth
    integer :volume_number
    integer :issue_number
    integer :serial_number
    integer :start_page
    integer :end_page
    integer :number_of_pages
    float :price
    integer :series_statement_ids, multiple: true
    boolean :repository_content
    # for OpenURL
    text :aulast do
      creators.pluck(:last_name)
    end
    text :aufirst do
      creators.pluck(:first_name)
    end
    # OTC start
    string :creator, multiple: true do
      creator.map{|au| au.gsub(' ', '')}
    end
    text :au do
      creator
    end
    text :atitle do
      if serial? && root_series_statement.nil?
        titles
      end
    end
    text :btitle do
      title unless serial?
    end
    text :jtitle do
      if serial?
        if root_series_statement
          root_series_statement.titles
        else
          titles
        end
      end
    end
    text :isbn do # 前方一致検索のためtext指定を追加
      isbn_characters
    end
    text :issn do # 前方一致検索のためtext指定を追加
      if series_statements.exists?
        [identifier_contents(:issn), (series_statements.map{|s| s.manifestation.identifier_contents(:issn)})].flatten.uniq.compact
      else
        identifier_contents(:issn)
      end
    end
    text :identifier do
      other_identifiers = identifiers.joins(:identifier_type).merge(IdentifierType.where.not(name: [:isbn, :issn]))
      other_identifiers.pluck(:body)
    end
    string :sort_title
    string :doi, multiple: true do
      identifier_contents(:doi)
    end
    boolean :serial do
      serial?
    end
    boolean :series_master do
      series_master?
    end
    boolean :resource_master do
      if serial?
        if series_master?
          true
        else
          false
        end
      else
        true
      end
    end
    time :acquired_at
  end

  has_one_attached :attachment

  validates :original_title, presence: true
  validates :start_page, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :end_page, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :height, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :width, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :depth, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :manifestation_identifier, uniqueness: true, allow_blank: true
  validates :pub_date, format: {with: /\A\[{0,1}\d+([\/-]\d{0,2}){0,2}\]{0,1}\z/}, allow_blank: true
  validates :access_address, url: true, allow_blank: true, length: {maximum: 255}
  validates :issue_number, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :volume_number, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :serial_number, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  validates :edition, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  before_save :set_date_of_publication, :set_number
  before_save do
    attachment.purge if delete_attachment == '1'
  end
  after_create :clear_cached_numdocs
  after_destroy :index_series_statement
  after_save :index_series_statement
  after_touch do |manifestation|
    manifestation.index
    manifestation.index_series_statement
    Sunspot.commit
  end
  strip_attributes only: [:manifestation_identifier, :pub_date, :original_title]
  paginates_per 10

  attr_accessor :during_import, :parent_id, :delete_attachment

  def set_date_of_publication
    return if pub_date.blank?

    year = Time.utc(pub_date.rjust(4, "0").to_i).year rescue nil
    begin
      date = Time.zone.parse(pub_date.rjust(4, "0"))
      if date.year != year
        raise ArgumentError
      end
    rescue ArgumentError, TZInfo::AmbiguousTime
      date = nil
    end

    pub_date_string = pub_date.rjust(4, "0").split(';').first.gsub(/[\[\]]/, '')
    if pub_date_string.length == 4
      date = Time.zone.parse(Time.utc(pub_date_string).to_s).beginning_of_day
    else
      while date.nil?
        pub_date_string += '-01'
        break if pub_date_string =~ /-01-01-01$/

        begin
          date = Time.zone.parse(pub_date_string)
          if date.year != year
            raise ArgumentError
          end
        rescue ArgumentError
          date = nil
        rescue TZInfo::AmbiguousTime
          date = nil
          self.year_of_publication = pub_date_string.to_i if pub_date_string =~ /^\d+$/
          break
        end
      end
    end

    if date
      self.year_of_publication = date.year
      self.month_of_publication = date.month
      if date.year.positive?
        self.date_of_publication = date
      end
    end
  end

  def self.cached_numdocs
    Rails.cache.fetch("manifestation_search_total"){Manifestation.search.total}
  end

  def clear_cached_numdocs
    Rails.cache.delete("manifestation_search_total")
  end

  def parent_of_series
    original_manifestations
  end

  def number_of_pages
    if start_page && end_page
      end_page.to_i - start_page.to_i + 1
    end
  end

  def titles
    title = []
    title << original_title.to_s.strip
    title << title_transcription.to_s.strip
    title << title_alternative.to_s.strip
    title << volume_number_string
    title << issue_number_string
    title << serial_number.to_s
    title << edition_string
    title << series_statements.map{|s| s.titles}
    #title << original_title.wakati
    #title << title_transcription.wakati rescue nil
    #title << title_alternative.wakati rescue nil
    title.flatten
  end

  def url
    #access_address
    "#{LibraryGroup.site_config.url}#{self.class.to_s.tableize}/#{id}"
  end

  def creator
    creators.collect(&:name).flatten
  end

  def contributor
    contributors.collect(&:name).flatten
  end

  def publisher
    publishers.collect(&:name).flatten
  end

  def title
    titles
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil, current_user = nil)
    return nil if self.cached_numdocs < 5

    if current_user&.role
      current_role_id = current_user.role.id
    else
      current_role_id = 1
    end

    # TODO: ヒット件数が0件のキーワードがあるときに指摘する
    response = Manifestation.search do
      fulltext keyword if keyword
      with(:required_role_id).less_than_or_equal_to current_role_id
      order_by(:random)
      paginate page: 1, per_page: 1
    end
    response.results.first
  end

  def extract_text
    return unless attachment.attached?
    return unless ENV['ENJU_LEAF_EXTRACT_TEXT'] == 'true'

    if ENV['ENJU_LEAF_EXTRACT_FILESIZE_LIMIT'].present?
      filesize_limit = ENV['ENJU_LEAF_EXTRACT_FILESIZE_LIMIT'].to_i
    else
      filesize_limit = 2097152
    end

    if attachment.byte_size > filesize_limit
      Rails.logger.error("#{attachment.filename} (size: #{attachment.byte_size} byte(s)) exceeds filesize limit #{ENV['ENJU_LEAF_EXTRACT_FILESIZE_LIMIT']} bytes")
      return ''
    end

    client = Faraday.new(url: ENV['TIKA_URL'] || 'http://tika:9998') do |conn|
      conn.adapter :net_http
    end

    response = client.put('/tika/text') do |req|
      req.headers['Content-Type'] = attachment.content_type
      req.headers['Content-Length'] = attachment.byte_size.to_s
      req.body = Faraday::UploadIO.new(StringIO.new(attachment.download), attachment.content_type)
    end

    payload = JSON.parse(response.body)['X-TIKA:content'].strip.tr("\t", " ").gsub(/\r?\n/, "")
    payload
  end

  def created(agent)
    creates.find_by(agent_id: agent.id)
  end

  def realized(agent)
    realizes.find_by(agent_id: agent.id)
  end

  def produced(agent)
    produces.find_by(agent_id: agent.id)
  end

  def sort_title
    if series_master?
      if root_series_statement.title_transcription?
        NKF.nkf('-w --katakana', root_series_statement.title_transcription)
      else
        root_series_statement.original_title
      end
    elsif title_transcription?
      NKF.nkf('-w --katakana', title_transcription)
      else
        original_title
    end
  end

  def self.find_by_isbn(isbn)
    identifier_type = IdentifierType.find_by(name: 'isbn')
    return nil unless identifier_type

    Manifestation.includes(identifiers: :identifier_type).where("identifiers.body": isbn, "identifier_types.name": 'isbn')
  end

  def index_series_statement
    series_statements.map{|s| s.index
                              s.root_manifestation&.index}
  end

  def acquired_at
    items.order(:acquired_at).first.try(:acquired_at)
  end

  def series_master?
    return true if root_series_statement

    false
  end

  def web_item
    items.find_by(shelf_id: Shelf.web.id)
  end

  def set_agent_role_type(agent_lists, options = {scope: :creator})
    agent_lists.each do |agent_list|
      name_and_role = agent_list[:full_name].split('||')
      if agent_list[:agent_identifier].present?
        agent = Agent.find_by(agent_identifier: agent_list[:agent_identifier])
      end
      agent ||= Agent.find_by(full_name: name_and_role[0])
      next unless agent

      type = name_and_role[1].to_s.strip

      case options[:scope]
      when :creator
        type = 'author' if type.blank?
        role_type = CreateType.find_by(name: type)
        create = Create.find_by(work_id: id, agent_id: agent.id)
        if create
          create.create_type = role_type
          create.save(validate: false)
        end
      when :publisher
        type = 'publisher' if role_type.blank?
        produce = Produce.find_by(manifestation_id: id, agent_id: agent.id)
        if produce
          produce.produce_type = ProduceType.find_by(name: type)
          produce.save(validate: false)
        end
      else
        raise "#{options[:scope]} is not supported!"
      end
    end
  end

  def set_number
    self.volume_number = volume_number_string.scan(/\d*/).map{|s| s.to_i if s =~ /\d/}.compact.first if volume_number_string && !volume_number?
    self.issue_number = issue_number_string.scan(/\d*/).map{|s| s.to_i if s =~ /\d/}.compact.first if issue_number_string && !issue_number?
    self.edition = edition_string.scan(/\d*/).map{|s| s.to_i if s =~ /\d/}.compact.first if edition_string && !edition?
  end

  def pub_dates
    return [] unless pub_date

    pub_date_array = pub_date.split(';')
    pub_date_array.map{|pub_date_string|
      date = nil
      while date.nil? do
        pub_date_string += '-01'
        break if pub_date_string =~ /-01-01-01$/

        begin
          date = Time.zone.parse(pub_date_string)
        rescue ArgumentError
        rescue TZInfo::AmbiguousTime
        end
      end
      date
    }.compact
  end

  def latest_issue
    if series_master?
      derived_manifestations.where.not(date_of_publication: nil).order('date_of_publication DESC').first
    end
  end

  def first_issue
    if series_master?
      derived_manifestations.where.not(date_of_publication: nil).order('date_of_publication DESC').first
    end
  end

  def identifier_contents(name)
    identifiers.id_type(name).order(:position).pluck(:body)
  end

  # CSVのヘッダ
  # @param [String] role 権限
  def self.csv_header(role: 'Guest')
    Manifestation.new.to_hash(role: role).keys
  end

  # CSV出力用のハッシュ
  # @param [String] role 権限
  def to_hash(role: 'Guest')
    record = {
      manifestation_id: id,
      original_title: original_title,
      title_alternative: title_alternative,
      title_transcription: title_transcription,
      statement_of_responsibility: statement_of_responsibility,
      serial: serial,
      manifestation_identifier: manifestation_identifier,
      creator: creates.map{|create|
        if create.create_type
          "#{create.agent.full_name}||#{create.create_type.name}"
        else
          "#{create.agent.full_name}"
        end
      }.join('//'),
      contributor: realizes.map{|realize|
        if realize.realize_type
          "#{realize.agent.full_name}||#{realize.realize_type.name}"
        else
          "#{realize.agent.full_name}"
        end
      }.join('//'),
      publisher: produces.map{|produce|
        if produce.produce_type
          "#{produce.agent.full_name}||#{produce.produce_type.name}"
        else
          "#{produce.agent.full_name}"
        end
      }.join('//'),
      pub_date: date_of_publication,
      year_of_publication: year_of_publication,
      publication_place: publication_place,
      manifestation_created_at: created_at,
      manifestation_updated_at: updated_at,
      carrier_type: carrier_type.name,
      content_type: manifestation_content_type.name,
      frequency: frequency.name,
      language: language.name,
      isbn: identifier_contents(:isbn).join('//'),
      issn: identifier_contents(:issn).join('//'),
      volume_number: volume_number,
      volume_number_string: volume_number_string,
      edition: edition,
      edition_string: edition_string,
      issue_number: issue_number,
      issue_number_string: issue_number_string,
      serial_number: serial_number,
      extent: extent,
      start_page: start_page,
      end_page: end_page,
      dimensions: dimensions,
      height: height,
      width: width,
      depth: depth,
      manifestation_price: price,
      access_address: access_address,
      manifestation_required_role: required_role.name,
      abstract: abstract,
      description: description,
      note: note
    }

    IdentifierType.find_each do |type|
      next if ['issn', 'isbn', 'jpno', 'ncid', 'lccn', 'doi'].include?(type.name.downcase.strip)

      record[:"identifier:#{type.name.to_sym}"] = identifiers.where(identifier_type: type).pluck(:body).join('//')
    end

    series = series_statements.order(:position)
    record.merge!(
      series_statement_id: series.pluck(:id).join('//'),
      series_statement_original_title: series.pluck(:original_title).join('.//'),
      series_statement_title_subseries: series.pluck(:title_subseries).join('//'),
      series_statement_title_subseries_transcription: series.pluck(:title_subseries_transcription).join('//'),
      series_statement_title_transcription: series.pluck(:title_transcription).join('//'),
      series_statement_creator: series.pluck(:creator_string).join('//'),
      series_statement_volume_number: series.pluck(:volume_number_string).join('//'),
      series_statement_series_master: series.pluck(:series_master).join('//'),
      series_statement_root_manifestation_id: series.pluck(:root_manifestation_id).join('//'),
      series_statement_manifestation_id: series.pluck(:manifestation_id).join('//'),
      series_statement_position: series.pluck(:position).join('//'),
      series_statement_note: series.pluck(:note).join('//'),
      series_statement_created_at: series.pluck(:created_at).join('//'),
      series_statement_updated_at: series.pluck(:updated_at).join('//')
    )

    if ['Administrator', 'Librarian'].include?(role)
      record.merge!({
        memo: memo
      })
      ManifestationCustomProperty.order(:position).each do |custom_property|
        custom_value = manifestation_custom_values.find_by(manifestation_custom_property: custom_property)
        record[:"manifestation:#{custom_property.name}"] = custom_value&.value
      end
    end

    if defined?(EnjuSubject)
      SubjectHeadingType.find_each do |type|
        record[:"subject:#{type.name}"] = subjects.where(subject_heading_type: type).pluck(:term).join('//')
      end
      ClassificationType.find_each do |type|
        record[:"classification:#{type.name}"] = classifications.where(classification_type: type).pluck(:category).map(&:to_s).join('//')
      end
    end

    record["jpno"] = jpno_record&.body
    record["ncid"] = ncid_record&.body
    record["lccn"] = identifier_contents(:lccn).first
    record["doi"] = doi_record&.body
    record["iss_itemno"] = identifier_contents(:iss_itemno).first

    record
  end

  # TSVでのエクスポート
  # @param [String] role 権限
  # @param [String] col_sep 区切り文字
  def self.export(role: 'Guest', col_sep: "\t")
    file = Tempfile.create('manifestation_export') do |f|
      f.write (Manifestation.csv_header(role: role) + Item.csv_header(role: role)).to_csv(col_sep: col_sep)
      Manifestation.find_each do |manifestation|
        if manifestation.items.exists?
          manifestation.items.each do |item|
            f.write (manifestation.to_hash(role: role).values + item.to_hash(role: role).values).to_csv(col_sep: col_sep)
          end
        else
          f.write manifestation.to_hash(role: role).values.to_csv(col_sep: col_sep)
        end
      end

      f.rewind
      f.read
    end

    file
  end

  def root_series_statement
    series_statements.find_by(root_manifestation_id: id)
  end

  def isbn_characters
    identifier_contents(:isbn).map{|i|
      isbn10 = isbn13 = isbn10_dash = isbn13_dash = nil
      isbn10 = Lisbn.new(i).isbn10
      isbn13 = Lisbn.new(i).isbn13
      isbn10_dash = Lisbn.new(isbn10).isbn_with_dash if isbn10
      isbn13_dash = Lisbn.new(isbn13).isbn_with_dash if isbn13
      [
        isbn10, isbn13, isbn10_dash, isbn13_dash
      ]
    }.flatten
  end

  def set_custom_property(row)
    ManifestationCustomProperty.find_each do |property|
      if row[property]
        custom_value = ManifestationCustomValue.new(
          manifestation: self,
          manifestation_custom_property: property,
          value: row[property]
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: manifestations
#
#  id                              :bigint           not null, primary key
#  original_title                  :text             not null
#  title_alternative               :text
#  title_transcription             :text
#  classification_number           :string
#  manifestation_identifier        :string
#  date_of_publication             :datetime
#  date_copyrighted                :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  access_address                  :string
#  language_id                     :bigint           default(1), not null
#  carrier_type_id                 :bigint           default(1), not null
#  start_page                      :integer
#  end_page                        :integer
#  height                          :integer
#  width                           :integer
#  depth                           :integer
#  price                           :integer
#  fulltext                        :text
#  volume_number_string            :string
#  issue_number_string             :string
#  serial_number_string            :string
#  edition                         :integer
#  note                            :text
#  repository_content              :boolean          default(FALSE), not null
#  lock_version                    :integer          default(0), not null
#  required_role_id                :bigint           default(1), not null
#  required_score                  :integer          default(0), not null
#  frequency_id                    :bigint           default(1), not null
#  subscription_master             :boolean          default(FALSE), not null
#  nii_type_id                     :bigint
#  title_alternative_transcription :text
#  description                     :text
#  abstract                        :text
#  available_at                    :datetime
#  valid_until                     :datetime
#  date_submitted                  :datetime
#  date_accepted                   :datetime
#  date_captured                   :datetime
#  pub_date                        :string
#  edition_string                  :string
#  volume_number                   :integer
#  issue_number                    :integer
#  serial_number                   :integer
#  content_type_id                 :bigint           default(1)
#  year_of_publication             :integer
#  month_of_publication            :integer
#  fulltext_content                :boolean
#  serial                          :boolean
#  statement_of_responsibility     :text
#  publication_place               :text
#  extent                          :text
#  dimensions                      :text
#  memo                            :text
#

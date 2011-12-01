class Manifestation < ActiveRecord::Base
  scope :periodical_master, where(:periodical => false)
  scope :periodical_children, where(:periodical => true)
  has_many :creates, :dependent => :destroy, :foreign_key => 'work_id'
  has_many :creators, :through => :creates, :source => :patron
  has_many :realizes, :dependent => :destroy, :foreign_key => 'expression_id'
  has_many :contributors, :through => :realizes, :source => :patron
  has_many :produces, :dependent => :destroy, :foreign_key => 'manifestation_id'
  has_many :publishers, :through => :produces, :source => :patron
  has_many :exemplifies, :foreign_key => 'manifestation_id'
  has_many :items, :through => :exemplifies #, :foreign_key => 'manifestation_id'
  has_many :children, :foreign_key => 'parent_id', :class_name => 'ManifestationRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'ManifestationRelationship', :dependent => :destroy
  has_many :derived_manifestations, :through => :children, :source => :child
  has_many :original_manifestations, :through => :parents, :source => :parent
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  belongs_to :language
  belongs_to :carrier_type
  belongs_to :content_type
  has_one :series_has_manifestation, :dependent => :destroy
  has_one :series_statement, :through => :series_has_manifestation
  belongs_to :manifestation_relationship_type
  belongs_to :frequency
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_one :resource_import_result

  searchable do
    text :title, :default_boost => 2 do
      titles
    end
    text :fulltext, :note, :creator, :contributor, :publisher, :description
    string :title, :multiple => true
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
    string :isbn, :multiple => true do
      [isbn, isbn10, wrong_isbn]
    end
    string :issn
    string :lccn
    string :nbn
    string :carrier_type do
      carrier_type.name
    end
    string :library, :multiple => true do
      items.map{|i| i.shelf.library.name}
    end
    string :language do
      language.try(:name)
    end
    string :item_identifier, :multiple => true do
      items.collect(&:item_identifier)
    end
    string :shelf, :multiple => true do
      items.collect{|i| "#{i.shelf.library.name}_#{i.shelf.name}"}
    end
    time :created_at
    time :updated_at
    time :deleted_at
    time :date_of_publication
    integer :creator_ids, :multiple => true
    integer :contributor_ids, :multiple => true
    integer :publisher_ids, :multiple => true
    integer :item_ids, :multiple => true
    integer :original_manifestation_ids, :multiple => true
    integer :required_role_id
    integer :height
    integer :width
    integer :depth
    integer :volume_number, :multiple => true
    integer :issue_number, :multiple => true
    integer :serial_number, :multiple => true
    integer :start_page
    integer :end_page
    integer :number_of_pages
    float :price
    integer :series_statement_id do
      series_has_manifestation.try(:series_statement_id)
    end
    boolean :repository_content
    # for OpenURL
    text :aulast do
      creators.map{|creator| creator.last_name}
    end
    text :aufirst do
      creators.map{|creator| creator.first_name}
    end
    # OTC start
    string :creator, :multiple => true do
      creator.map{|au| au.gsub(' ', '')}
    end
    text :au do
      creator
    end
    text :atitle do
      title if original_manifestations.present? # 親がいることが条件
    end
    text :btitle do
      title if frequency_id == 1  # 発行頻度1が単行本
    end
    text :jtitle do
      if frequency_id != 1  # 雑誌の場合
        title
      else                  # 雑誌以外（雑誌の記事も含む）
        titles = []
        original_manifestations.each do |m|
          if m.frequency_id != 1
            titles << m.title
          end
        end
        titles.flatten
      end
    end
    text :isbn do  # 前方一致検索のためtext指定を追加
      [isbn, isbn10, wrong_isbn]
    end
    text :issn  # 前方一致検索のためtext指定を追加
    #text :ndl_jpno do
      # TODO 詳細不明
    #end
    #string :ndl_dpid do
      # TODO 詳細不明
    #end
    # OTC end
    string :sort_title
    boolean :periodical do
      periodical?
    end
    boolean :periodical_master do
      periodical_master?
    end
    time :acquired_at
  end

  enju_manifestation_viewer
  enju_ndl_porta
  #enju_amazon
  #enju_oai
  #enju_calil_check
  #enju_cinii
  #has_ipaper_and_uses 'Paperclip'
  #enju_scribd
  has_paper_trail
  if configatron.uploaded_file.storage == :s3
    has_attached_file :attachment, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml"
  else
    has_attached_file :attachment
  end

  validates_presence_of :original_title, :carrier_type, :language
  validates_associated :carrier_type, :language
  validates :start_page, :numericality => true, :allow_blank => true
  validates :end_page, :numericality => true, :allow_blank => true
  validates :isbn, :uniqueness => true, :allow_blank => true, :unless => proc{|manifestation| manifestation.series_statement}
  validates :nbn, :uniqueness => true, :allow_blank => true
  validates :manifestation_identifier, :uniqueness => true, :allow_blank => true
  validates :pub_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
  validates :access_address, :url => true, :allow_blank => true, :length => {:maximum => 255}
  validate :check_isbn, :check_issn, :check_lccn, :unless => :during_import
  validates :issue_number, :numericality => {:greater_than => 0}, :allow_blank => true
  validates :volume_number, :numericality => {:greater_than => 0}, :allow_blank => true
  validates :serial_number, :numericality => {:greater_than => 0}, :allow_blank => true
  validates :edition, :numericality => {:greater_than => 0}, :allow_blank => true
  before_validation :set_wrong_isbn, :check_issn, :check_lccn, :if => :during_import
  before_validation :convert_isbn, :if => :isbn_changed?
  before_create :set_digest
  after_create :clear_cached_numdocs
  before_save :set_date_of_publication
  before_save :set_periodical
  after_save :index_series_statement
  after_destroy :index_series_statement
  normalize_attributes :manifestation_identifier, :pub_date, :isbn, :issn, :nbn, :lccn, :original_title
  attr_accessor :during_import, :series_statement_id

  def self.per_page
    10
  end

  def check_isbn
    if isbn.present?
      unless ISBN_Tools.is_valid?(isbn)
        errors.add(:isbn)
      end
    end
  end

  def check_issn
    self.issn = ISBN_Tools.cleanup(issn)
    if issn.present?
      unless StdNum::ISSN.valid?(issn)
        errors.add(:issn)
      end
    end
  end

  def check_lccn
    if lccn.present?
      unless StdNum::LCCN.valid?(lccn)
        errors.add(:lccn)
      end
    end
  end

  def set_wrong_isbn
    if isbn.present?
      unless ISBN_Tools.is_valid?(isbn)
        self.wrong_isbn
        self.isbn = nil
      end
    end
  end

  def convert_isbn
    num = ISBN_Tools.cleanup(isbn) if isbn
    if num
      if num.length == 10
        self.isbn10 = num
        self.isbn = ISBN_Tools.isbn10_to_isbn13(num)
      elsif num.length == 13
        self.isbn10 = ISBN_Tools.isbn13_to_isbn10(num)
      end
    end
  end

  def set_date_of_publication
    return if pub_date.blank?
    begin
      date = Time.zone.parse("#{pub_date}")
    rescue ArgumentError
      begin
        date = Time.zone.parse("#{pub_date}-01")
      rescue ArgumentError
        begin
          date = Time.zone.parse("#{pub_date}-01-01")
        rescue ArgumentError
          nil
        end
      end
    end
    self.date_of_publication = date
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

  def serial?
    if new_record?
      if SeriesStatement.where(:id => series_statement_id).first.try(:periodical)
        return true
      end
    else
      if series_statement.try(:periodical)
        return true
      elsif periodical?
        return true unless series_statement.try(:root_manifestation) == self
      end
    end
    false
  end

  def number_of_pages
    if self.start_page and self.end_page
      page = self.end_page.to_i - self.start_page.to_i + 1
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
    title << series_statement.titles if series_statement
    #title << original_title.wakati
    #title << title_transcription.wakati rescue nil
    #title << title_alternative.wakati rescue nil
    title.flatten
  end

  def url
    #access_address
    "#{LibraryGroup.site_config.url}#{self.class.to_s.tableize}/#{self.id}"
  end

  def set_serial_information
    return nil unless periodical?
    if new_record?
      series_statement = SeriesStatement.where(:id => series_statement_id).first
      manifestation = series_statement.try(:last_issue)
    else
      manifestation = series_statement.try(:last_issue)
    end
    if manifestation
      self.original_title = manifestation.original_title
      self.title_transcription = manifestation.title_transcription
      self.title_alternative = manifestation.title_alternative
      self.issn = series_statement.issn
      # TODO: 雑誌ごとに巻・号・通号のパターンを設定できるようにする
      if manifestation.serial_number.to_i > 0
        self.serial_number = manifestation.serial_number.to_i + 1
        if manifestation.issue_number.to_i > 0
          self.issue_number = manifestation.issue_number.to_i + 1
        else
          self.issue_number = manifestation.issue_number
        end
        self.volume_number = manifestation.volume_number
      else
        if manifestation.issue_number.to_i > 0
          self.issue_number = manifestation.issue_number.to_i + 1
          self.volume_number = manifestation.volume_number
        else
          if manifestation.volume_number.to_i > 0
            self.volume_number = manifestation.volume_number.to_i + 1
          end
        end
      end
    end
    self
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

  def hyphenated_isbn
    ISBN_Tools.hyphenate(isbn)
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil)
    return nil if self.cached_numdocs < 5
    manifestation = nil
    # TODO: ヒット件数が0件のキーワードがあるときに指摘する
    response = Manifestation.search(:include => [:creators, :contributors, :publishers, :items]) do
      fulltext keyword if keyword
      order_by(:random)
      paginate :page => 1, :per_page => 1
    end
    manifestation = response.results.first
  end

  def set_digest(options = {:type => 'sha1'})
    if attachment.queued_for_write[:original]
      if File.exists?(attachment.queued_for_write[:original])
        self.file_hash = Digest::SHA1.hexdigest(File.open(attachment.queued_for_write[:original].path, 'rb').read)
      end
    end
  end

  def extract_text
    extractor = ExtractContent::Extractor.new
    text = Tempfile::new("text")
    case self.attachment_content_type
    when "application/pdf"
      system("pdftotext -q -enc UTF-8 -raw #{attachment(:path)} #{text.path}")
      self.fulltext = text.read
    when "application/msword"
      system("antiword #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = text.read
    when "application/vnd.ms-excel"
      system("xlhtml #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "application/vnd.ms-powerpoint"
      system("ppthtml #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "text/html"
      # TODO: 日本語以外
      system("w3m -dump #{attachment(:path)} 2> /dev/null | nkf -w > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    end

    #self.indexed_at = Time.zone.now
    save(:validate => false)
    text.close
  end

  def created(patron)
    creates.where(:patron_id => patron.id).first
  end

  def realized(patron)
    realizes.where(:patron_id => patron.id).first
  end

  def produced(patron)
    produces.where(:patron_id => patron.id).first
  end

  def sort_title
    NKF.nkf('-w --katakana', title_transcription) if title_transcription
  end

  def classifications
    subjects.collect(&:classifications).flatten
  end

  def self.find_by_isbn(isbn)
    if ISBN_Tools.is_valid?(isbn)
      ISBN_Tools.cleanup!(isbn)
      if isbn.size == 10
        Manifestation.where(:isbn => ISBN_Tools.isbn10_to_isbn13(isbn)).first || Manifestation.where(:isbn => isbn).first
      else
        Manifestation.where(:isbn => isbn).first || Manifestation.where(:isbn => ISBN_Tools.isbn13_to_isbn10(isbn)).first
      end
    end
  end

  def index_series_statement
    series_statement.try(:index)
  end

  def acquired_at
    items.order(:acquired_at).first.try(:acquired_at)
  end

  def set_periodical
    unless series_statement
      series_statement = SeriesStatement.where(:id => series_statement_id).first
    end
  end

  def root_of_series?
    return true if series_statement.try(:root_manifestation) == self
    false
  end

  def periodical_master?
    if series_statement
      return true if series_statement.periodical and root_of_series?
    end
    false
  end

  def periodical?
    if self.new_record?
      series_statement = SeriesStatement.where(:id => series_statement_id).first
    end
    if series_statement.try(:periodical)
      return true unless root_of_series?
    end
    false
  end

  def web_item
    items.where(:shelf_id => Shelf.web.id).first
  end

  if defined?(EnjuCirculation)
    searchable do
      boolean :reservable do
        items.for_checkout.exists?
      end
    end
  end

  if defined?(EnjuSubject)
    has_many :work_has_subjects, :foreign_key => 'work_id', :dependent => :destroy
    has_many :subjects, :through => :work_has_subjects

    searchable do
      text :subject do
        subjects.collect(&:term) + subjects.collect(&:term_transcription)
      end
      string :subject, :multiple => true do
        subjects.collect(&:term) + subjects.collect(&:term_transcription)
      end
      string :classification, :multiple => true do
        classifications.collect(&:category)
      end
      integer :subject_ids, :multiple => true
    end
  end

  if defined?(EnjuCirculation)
  end

  if defined?(EnjuBookmark)
    has_many :bookmarks, :include => :tags, :dependent => :destroy, :foreign_key => :manifestation_id
    has_many :users, :through => :bookmarks

    searchable do
      string :tag, :multiple => true do
        tags.collect(&:name)
      end
      text :tag do
        tags.collect(&:name)
      end
    end

    def bookmarked?(user)
      return true if user.bookmarks.where(:url => url).first
      false
    end

    def tags
      if self.bookmarks.first
        self.bookmarks.tag_counts
      else
        []
      end
    end
  end

  if defined?(EnjuQuestion)
    def questions(options = {})
      id = self.id
      options = {:page => 1, :per_page => Question.per_page}.merge(options)
      page = options[:page]
      per_page = options[:per_page]
      user = options[:user]
      Question.search do
        with(:manifestation_id).equal_to id
        any_of do
          unless user.try(:has_role?, 'Librarian')
            with(:shared).equal_to true
          #  with(:username).equal_to user.try(:username)
          end
        end
        paginate :page => page, :per_page => per_page
      end.results
    end
  end
end

# == Schema Information
#
# Table name: manifestations
#
#  id                              :integer         not null, primary key
#  original_title                  :text            not null
#  title_alternative               :text
#  title_transcription             :text
#  classification_number           :string(255)
#  manifestation_identifier        :string(255)
#  date_of_publication             :datetime
#  date_copyrighted                :datetime
#  created_at                      :datetime
#  updated_at                      :datetime
#  deleted_at                      :datetime
#  access_address                  :string(255)
#  language_id                     :integer         default(1), not null
#  carrier_type_id                 :integer         default(1), not null
#  extent_id                       :integer         default(1), not null
#  start_page                      :integer
#  end_page                        :integer
#  height                          :decimal(, )
#  width                           :decimal(, )
#  depth                           :decimal(, )
#  isbn                            :string(255)
#  isbn10                          :string(255)
#  wrong_isbn                      :string(255)
#  nbn                             :string(255)
#  lccn                            :string(255)
#  oclc_number                     :string(255)
#  issn                            :string(255)
#  price                           :integer
#  fulltext                        :text
#  volume_number_string            :string(255)
#  issue_number_string             :string(255)
#  serial_number_string            :string(255)
#  edition                         :integer
#  note                            :text
#  repository_content              :boolean         default(FALSE), not null
#  lock_version                    :integer         default(0), not null
#  required_role_id                :integer         default(1), not null
#  state                           :string(255)
#  required_score                  :integer         default(0), not null
#  frequency_id                    :integer         default(1), not null
#  subscription_master             :boolean         default(FALSE), not null
#  ipaper_id                       :integer
#  ipaper_access_key               :string(255)
#  attachment_file_name            :string(255)
#  attachment_content_type         :string(255)
#  attachment_file_size            :integer
#  attachment_updated_at           :datetime
#  title_alternative_transcription :text
#  description                     :text
#  abstract                        :text
#  available_at                    :datetime
#  valid_until                     :datetime
#  date_submitted                  :datetime
#  date_accepted                   :datetime
#  date_caputured                  :datetime
#  ndl_bib_id                      :string(255)
#  file_hash                       :string(255)
#  pub_date                        :string(255)
#  edition_string                  :string(255)
#  volume_number                   :integer
#  issue_number                    :integer
#  serial_number                   :integer
#  ndc                             :string(255)
#


class Resource < ActiveRecord::Base
  has_many :creates, :dependent => :destroy, :foreign_key => 'work_id'
  has_many :creators, :through => :creates, :source => :patron
  has_many :realizes, :dependent => :destroy, :foreign_key => 'expression_id'
  has_many :contributors, :through => :realizes, :source => :patron
  has_many :produces, :dependent => :destroy, :foreign_key => 'manifestation_id'
  has_many :publishers, :through => :produces, :source => :patron
  has_many :exemplifies, :foreign_key => 'manifestation_id'
  has_many :items, :through => :exemplifies #, :foreign_key => 'manifestation_id'
  has_many :children, :foreign_key => 'parent_id', :class_name => 'ResourceRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'ResourceRelationship', :dependent => :destroy
  has_many :derived_resources, :through => :children, :source => :child
  has_many :original_resources, :through => :parents, :source => :parent
  has_many :work_has_subjects, :foreign_key => 'work_id', :dependent => :destroy
  has_many :subjects, :through => :work_has_subjects
  has_many :bookmarks, :include => :tags, :dependent => :destroy, :foreign_key => :manifestation_id
  has_many :users, :through => :bookmarks
  has_many :reserves, :foreign_key => :manifestation_id
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  belongs_to :language
  belongs_to :carrier_type
  belongs_to :content_type
  belongs_to :series_statement
  belongs_to :resource_relationship_type
  belongs_to :frequency
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true

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
    text :tag do
      tags.collect(&:name)
    end
    time :created_at
    string :isbn, :multiple => true do
      [isbn, isbn10, wrong_isbn]
    end
    string :issn
    string :lccn
    string :nbn
    string :tag, :multiple => true do
      tags.collect(&:name)
    end
    string :subject, :multiple => true do
      subjects.collect(&:term)
    end
    string :carrier_type do
      carrier_type.name
    end
    string :library, :multiple => true do
      items.map{|i| i.shelf.library.name}
    end
    string :language do
      language.name
    end
    string :item_identifier, :multiple => true do
      items.collect(&:item_identifier)
    end
    time :created_at
    time :updated_at
    time :deleted_at
    time :date_of_publication
    integer :creator_ids, :multiple => true
    integer :contributor_ids, :multiple => true
    integer :publisher_ids, :multiple => true
    integer :item_ids, :multiple => true
    integer :original_resource_ids, :multiple => true
    integer :subject_ids, :multiple => true
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
    boolean :reservable do
     self.reservable?
    end
    integer :series_statement_id
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
      title if original_resources.present? # 親がいることが条件
    end
    text :btitle do
      title if frequency_id == 1  # 発行頻度1が単行本
    end
    text :jtitle do
      if frequency_id != 1  # 雑誌の場合
        title
      else                  # 雑誌以外（雑誌の記事も含む）
        titles = []
        original_resources.each do |m|
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
    text :ndl_jpno do
      # TODO 詳細不明
    end
    string :ndl_dpid do
      # TODO 詳細不明
    end
    # OTC end
    string :sort_title
  end

  enju_amazon
  enju_manifestation_viewer
  enju_mozshot
  enju_oai
  enju_calil_check
  has_paper_trail
  has_attached_file :attachment

  validates_presence_of :original_title, :carrier_type, :language
  validates_associated :carrier_type, :language
  validates_numericality_of :start_page, :end_page, :allow_blank => true
  validates_length_of :access_address, :maximum => 255, :allow_blank => true
  validates_uniqueness_of :isbn, :allow_blank => true
  validates_uniqueness_of :nbn, :allow_blank => true
  validates_uniqueness_of :manifestation_identifier, :allow_blank => true
  validates_format_of :access_address, :with => URI::regexp(%w(http https)) , :allow_blank => true
  validate :check_isbn
  before_validation :convert_isbn
  normalize_attributes :manifestation_identifier, :date_of_publication, :isbn, :issn, :nbn, :lccn

  def check_isbn
    if isbn.present?
      errors.add(:isbn) unless ISBN_Tools.is_valid?(isbn)
      #set_wrong_isbn
    end
  end

  def set_wrong_isbn
    if isbn.present?
      wrong_isbn = isbn unless ISBN_Tools.is_valid?(isbn)
    end
  end

  def convert_isbn
    isbn = ISBN_Tools.cleanup(isbn) if isbn
    if isbn
      if isbn.length == 10
        isbn10 = isbn.dup
        isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
        isbn10 = isbn10
      elsif isbn.length == 13
        isbn10 = ISBN_Tools.isbn13_to_isbn10(isbn)
      end
    end
  end

  def self.per_page
    10
  end

  def self.cached_numdocs
    Rails.cache.fetch("resource_search_total"){self.search.total}
  end

  def next_reservation
    self.reserves.first(:order => ['reserves.created_at'])
  end

  def has_single_work?
    return true if works.size == 0
    if works.size == 1
      return true if works.first.original_title == original_title
    end
    false
  end

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

  def web_item
    items.first(:conditions => {:shelf_id => Shelf.web.id})
  end

  def serial?
    return true if series_statement
    #return true if parent_of_series
    #return true if frequency_id > 1
    false
  end

  def number_of_pages
    if self.start_page and self.end_page
      page = self.end_page.to_i - self.start_page.to_i + 1
    end
  end

  def tags
    unless self.bookmarks.empty?
      self.bookmarks.tag_counts
    else
      []
    end
  end

  def titles
    title = []
    title << original_title.to_s.strip
    title << title_transcription.to_s.strip
    title << title_alternative.to_s.strip
    #title << original_title.wakati
    #title << title_transcription.wakati rescue nil
    #title << title_alternative.wakati rescue nil
    title
  end

  def url
    #access_address
    "#{LibraryGroup.url}#{self.to_s.tablelize}/#{self.id}"
  end

  def available_checkout_types(user)
    user.user_group.user_group_has_checkout_types.available_for_carrier_type(self.carrier_type)
  end

  def checkout_period(user)
    available_checkout_types(user).collect(&:checkout_period).max || 0
  end
  
  def reservation_expired_period(user)
    available_checkout_types(user).collect(&:reservation_expired_period).max || 
0
 end
  
  def reservable?
    return false if self.items.for_checkout.empty?
    true
  end

  def patrons
    (creators + contributors + publishers).flatten
  end

  def bookmarked?(user)
    self.users.include?(user)
  end

  def set_serial_number
    if m = series_statement.try(:last_issue)
      self.original_title = m.original_title
      self.title_transcription = m.title_transcription
      self.title_alternative = m.title_alternative
      self.issn = m.issn
      unless m.serial_number_list.blank?
        self.serial_number_list = m.serial_number_list.to_i + 1
        unless m.issue_number_list.blank?
          self.issue_number_list = m.issue_number_list.split.last.to_i + 1
        else
          self.issue_number_list = m.issue_number_list
        end
        self.volume_number_list = m.volume_number_list
      else
        unless m.issue_number_list.blank?
          self.issue_number_list = m.issue_number_list.split.last.to_i + 1
          self.volume_number_list = m.volume_number_list
        else
          unless m.volume_number_list.blank?
            self.volume_number_list = m.volume_number_list.split.last.to_i + 1
          end
        end
      end
    end
    self
  end

  def is_reserved_by(user = nil)
    if user
      Reserve.waiting.first(:conditions => {:user_id => user.id, :manifestation_id => self.id})
    else
      false
    end
  end

  def is_reserved?
    if self.reserves.present?
      true
    else
      false
    end
  end

  def checkouts(start_date, end_date)
    Checkout.completed(start_date, end_date).all(:conditions => {:item_id => self.items.collect(&:id)})
  end

  def creator
    creators.collect(&:full_name)
  end

  def contributor
    contributors.collect(&:full_name)
  end

  def publisher
    publishers.collect(&:full_name)
  end

  def title
    titles
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil)
    return nil if self.cached_numdocs < 5
    resource = nil
    # TODO: ヒット件数が0件のキーワードがあるときに指摘する
    response = Resource.search(:include => [:creators, :contributors, :publishers, :subjects]) do
      fulltext keyword if keyword
      order_by(:random)
      paginate :page => 1, :per_page => 1
    end
    resource = response.results.first
    #if resource.nil?
    #  while resource.nil?
    #    resource = self.find(rand(self.cached_numdocs) + 1) rescue nil
    #  end
    #end
    #return resource
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
      system("elinks --dump 1 #{attachment(:path)} 2> /dev/null | nkf -w > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    end

    #self.indexed_at = Time.zone.now
    save(:validate => false)
    text.close
  end

  def parent_of_series
    original_resources
  end

  def created(patron)
    creates.first(:conditions => {:patron_id => patron.id})
  end

  def realized(patron)
    realizes.first(:conditions => {:patron_id => patron.id})
  end

  def produced(patron)
    produces.first(:conditions => {:patron_id => patron.id})
  end

  def volume_number
    volume_number_list.gsub(/\D/, ' ').split(" ") if volume_number_list
  end

  def issue_number
    issue_number_list.gsub(/\D/, ' ').split(" ") if issue_number_list
  end

  def serial_number
    serial_number_list.gsub(/\D/, ' ').split(" ") if serial_number_list
  end

  def sort_title
    NKF.nkf('-w --katakana', title_transcription) if title_transcription
  end
end

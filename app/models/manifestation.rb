# -*- encoding: utf-8 -*-
require EnjuTrunkFrbr::Engine.root.join('app', 'models', 'manifestation')
require EnjuTrunkCirculation::Engine.root.join('app', 'models', 'manifestation') if SystemConfiguration.get('internal_server')
class Manifestation < ActiveRecord::Base
  self.extend ItemsHelper
  has_many :creators, :through => :creates, :source => :patron, :order => :position
  has_many :contributors, :through => :realizes, :source => :patron, :order => :position
  has_many :publishers, :through => :produces, :source => :patron, :order => :position
  has_many :work_has_subjects, :foreign_key => 'work_id', :dependent => :destroy
  has_many :subjects, :through => :work_has_subjects, :order => :position
  has_many :reserves, :foreign_key => :manifestation_id, :order => :position
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  belongs_to :language
  belongs_to :carrier_type
  belongs_to :manifestation_type
  has_one :series_has_manifestation
  has_one :series_statement, :through => :series_has_manifestation
  belongs_to :frequency
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_one :resource_import_result
  has_many :purchase_requests
  has_many :table_of_contents

  belongs_to :manifestation_content_type, :class_name => 'ContentType', :foreign_key => 'content_type_id'
  belongs_to :country_of_publication, :class_name => 'Country', :foreign_key => 'country_of_publication_id'

  scope :without_master, where(:periodical_master => false)

  searchable do
    text :fulltext, :contributor, :article_title, :series_title, :exinfo_1, :exinfo_6
    text :title, :default_boost => 2 do
      titles
    end
    text :series_title do
      series_statement.try(:original_title)
    end
    text :spellcheck do
      titles
    end
    text :note do
      if root_of_series? # 雑誌の場合
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:note).compact
      else
        note
      end
    end
    text :description do
      if root_of_series? # 雑誌の場合
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:description).compact
      else
        description
      end
    end
    text :creator do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の著者のリストを取得する
        Patron.joins(:works).joins(:works => :series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          collect(&:name).compact
      else
        creator(true)
      end
    end
    text :publisher do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の出版社のリストを取得する
        Patron.joins(:manifestations => :series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          collect(&:name).compact
      else
        publisher(true)
      end
    end
    text :subject do
      subjects.collect(&:term) + subjects.collect(&:term_transcription)
    end
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
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号のISBNのリストを取得する
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map {|manifestation| [manifestation.isbn, manifestation.isbn10, manifestation.wrong_isbn] }.flatten.compact
      else
        [isbn, isbn10, wrong_isbn]
      end
    end
    string :issn, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号のISSNのリストを取得する
        issns = []
        issns << series_statement.try(:issn)
        issns << Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:issn).compact
        issns.flatten
      else
        [issn, series_statement.try(:issn)]
      end
    end
    string :marc_number
    string :lccn
    string :nbn
    string :subject, :multiple => true do
      subjects.collect(&:term) + subjects.collect(&:term_transcription)
    end
    string :classification, :multiple => true do
      classifications.collect(&:category)
    end
    string :carrier_type do
      carrier_type.name
    end
    string :manifestation_type, :multiple => true do
      manifestation_type.try(:name)
      #if series_statement.try(:id) 
      #  1
      #else
      #  0
      #end
    end
    string :library, :multiple => true do
      items.map{|i| i.shelf.library.name}
    end
    string :language do
      language.try(:name)
    end
    string :item_identifier, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の蔵書の蔵書情報IDのリストを取得する
        Item.joins(:manifestation => :series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          collect(&:item_identifier).compact
      else
        items(true).collect(&:item_identifier)
      end
    end
    string :removed_at, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の除籍日のリストを取得する
        Item.joins(:manifestation => :series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          collect(&:removed_at).compact
      else
        items(true).collect(&:removed_at)
      end
    end
    boolean :has_removed do
      has_removed?
    end
    boolean :is_article do
      self.article?
    end
    string :shelf, :multiple => true do
      items.collect{|i| "#{i.shelf.library.name}_#{i.shelf.name}"}
    end
    string :user, :multiple => true do
    end
    time :created_at
    time :updated_at
    time :deleted_at
    time :date_of_publication
    string :pub_date, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の出版日のリストを取得する
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:date_of_publication).compact
      else
        date_of_publication
      end
    end
    integer :creator_ids, :multiple => true
    integer :contributor_ids, :multiple => true
    integer :publisher_ids, :multiple => true
    integer :item_ids, :multiple => true
    integer :original_manifestation_ids, :multiple => true
    integer :subject_ids, :multiple => true
    integer :required_role_id
    integer :height
    integer :width
    integer :depth
    integer :volume_number, :multiple => true
    integer :issue_number, :multiple => true
    integer :serial_number, :multiple => true
    string :volume_number_string, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の出版日のリストを取得する
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:volume_number_string).compact
      else
        volume_number_string 
      end
    end
    string :issue_number_string, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の出版日のリストを取得する
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:issue_number_string).compact
      else
        issue_number_string 
      end
    end
    string :serial_number_string, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号の出版日のリストを取得する
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:serial_number_string).compact
      else
        serial_number_string 
      end
    end
    string :start_page
    string :end_page
    integer :number_of_pages
    string :number_of_pages, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号のページ数のリストを取得する
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:number_of_pages).compact
      else
        number_of_pages
      end
    end
    float :price
    string :price_string
    boolean :reservable do
      self.reservable?
    end
    boolean :in_process do
      self.in_process?
    end
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
    string :author do
      NKF.nkf('-w --katakana', creators[0].full_name_transcription) if creators[0] and creators[0].full_name_transcription
    end
    text :au do
      creator
    end
    text :atitle do
      title if series_statement.try(:periodical)
    end
    text :btitle do
      title unless series_statement.try(:periodical)
    end
    text :jtitle do
      if root_of_series? # 雑誌の場合
        series_statement.titles
      else                  # 雑誌以外（雑誌の記事も含む）
        original_manifestations.map{|m| m.title}.flatten
      end
    end
    text :isbn do  # 前方一致検索のためtext指定を追加
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号のISBNのリストを取得する
        Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map {|manifestation| [manifestation.isbn, manifestation.isbn10, manifestation.wrong_isbn] }.flatten.compact
      else
        [isbn, isbn10, wrong_isbn]
      end
    end
    text :issn do  # 前方一致検索のためtext指定を追加
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号のISSNのリストを取得する
        issns = []
        issns << series_statement.try(:issn)
        issns << Manifestation.joins(:series_statement).
          where(['series_statements.id = ?', self.series_statement.id]).
          map(&:issn).compact
        issns.flatten
      else
        [issn, series_statement.try(:issn)]
      end
    end
    text :ndl_jpno do
      # TODO 詳細不明
    end
    string :ndl_dpid do
      # TODO 詳細不明
    end
    # OTC end
    string :sort_title
    boolean :periodical do
      serial?
    end
    boolean :periodical_master
    time :acquired_at
    # 受入最古の所蔵情報を取得するためのSQLを構成する
    # (string :acquired_atでのみ使用する)
    item1 = Item.arel_table
    item2 = item1.alias

    mani1 = Manifestation.arel_table
    mani2 = mani1.alias

    exem1 = Exemplify.arel_table
    exem2 = exem1.alias

    shas1 = SeriesHasManifestation.arel_table
    shas2 = shas1.alias

    acquired_at_subq = item1.
      from(item2).
      project(
        shas2[:manifestation_id].as('grp_manifestation_id'),
        item2[:acquired_at].minimum.as('grp_min_acquired_at')
      ).
      join(exem2).on(
        item2[:id].eq(exem2[:item_id]).
        and(item2[:acquired_at].not_eq(nil))
      ).
      join(mani2).on(
        mani2[:id].eq(exem2[:manifestation_id])
      ).
      join(shas2).on(
        shas2[:manifestation_id].eq(mani2[:id]).
        and(shas2[:series_statement_id].eq(Arel.sql('?')))
      ).
      group(shas2[:manifestation_id]).
      as('t')

    acquired_at_q = item1.
      project(item1['*']).
      join(exem1).on(
        item1[:id].eq(exem1[:item_id]).
        and(item1[:acquired_at].not_eq(nil))
      ).
      join(mani1).on(
        mani1[:id].eq(exem1[:manifestation_id])
      ).
      join(shas1).on(
        shas1[:manifestation_id].eq(mani1[:id]).
        and(shas1[:series_statement_id].eq(Arel.sql('?')))
      ).
      join(acquired_at_subq).on(
        item1[:acquired_at].eq(acquired_at_subq['grp_min_acquired_at']).
        and(mani1[:id].eq(acquired_at_subq['grp_manifestation_id']))
      )
    string :acquired_at, :multiple => true do
      if root_of_series? # 雑誌の場合
        # 同じ雑誌の全号について、それぞれの最古の受入日のリストを取得する
        Item.find_by_sql([acquired_at_q.to_sql, series_statement.id, series_statement.id]).map(&:acquired_at)
      else
        acquired_at
      end
    end
    boolean :except_recent
    boolean :non_searchable do
      non_searchable?
    end
    string :exinfo_1
    string :exinfo_2
    string :exinfo_3
    string :exinfo_4
    string :exinfo_5
    string :exinfo_6
    string :exinfo_7
    string :exinfo_8
    string :exinfo_9
    string :exinfo_10
    text :extext_1
    text :extext_2
    text :extext_3
    text :extext_4
    text :extext_5
    integer :bookbinder_id, :multiple => true do
      items.collect(&:bookbinder_id).compact
    end
    integer :id
    integer :missing_issue
    boolean :circulation_status_in_process do
      true if items.collect(&:circulation_status_id).include?(CirculationStatus.find_by_name('In Process').id)
    end
    boolean :circulation_status_in_factory do
      true if items.collect(&:circulation_status_id).include?(CirculationStatus.find_by_name('In Factory').id)
    end
  end

  enju_manifestation_viewer
  enju_ndl_search
  #enju_amazon
  enju_oai
  #enju_calil_check
  #enju_cinii
  #has_ipaper_and_uses 'Paperclip'
  #enju_scribd
  has_paper_trail
  if Setting.uploaded_file.storage == :s3
    has_attached_file :attachment, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml"
  else
    has_attached_file :attachment
  end

  validates_presence_of :carrier_type, :language, :manifestation_type, :country_of_publication
  validates_associated :carrier_type, :language, :manifestation_type, :country_of_publication
  validates_numericality_of :acceptance_number, :allow_nil => true
  validate :check_rank
  before_validation :set_language, :if => :during_import
  before_validation :uniq_options
  before_validation :set_manifestation_type, :set_country_of_publication
  before_save :set_series_statement

  after_save :index_series_statement
  after_destroy :index_series_statement
  attr_accessor :during_import, :creator, :contributor, :publisher, :subject, 
                :creator_transcription, :publisher_transcription, :contributor_transcription, :subject_transcription

  paginates_per 10

  if defined?(EnjuBookmark)
    has_many :bookmarks, :include => :tags, :dependent => :destroy, :foreign_key => :manifestation_id
    has_many :users, :through => :bookmarks

    searchable do
      string :tag, :multiple => true do
        if root_of_series? # 雑誌の場合
          Bookmark.joins(:manifestation => :series_statement).
            where(['series_statements.id = ?', self.series_statement.id]).
            includes(:tags).
            tag_counts.collect(&:name).compact
        else
          tags.collect(&:name)
        end
      end
      text :tag do
        if root_of_series? # 雑誌の場合
          Bookmark.joins(:manifestation => :series_statement).
            where(['series_statements.id = ?', self.series_statement.id]).
            includes(:tags).
            tag_counts.collect(&:name).compact
        else
          tags.collect(&:name)
        end
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

  def check_rank
    if self.manifestation_type && self.manifestation_type.is_article?
      if self.items and self.items.size > 0
        unless self.items.map{ |item| item.rank.to_i }.compact.include?(0)
          errors[:base] << I18n.t('manifestation.not_has_original')
        end
      end
    end
  end

  def set_language
    self.language = Language.where(:name => "Japanese").first if self.language.nil?
  end

  def set_manifestation_type
    self.manifestation_type = ManifestationType.where(:name => 'unknown').first if self.manifestation_type.nil?
  end

  def root_of_series?
    return true if series_statement.try(:root_manifestation) == self
    false
  end

  def serial?
    if series_statement.try(:periodical) and !periodical_master
      return true unless root_of_series?
    end
    false
  end

  def article?
    self.try(:manifestation_type).try(:is_article?)
  end

  def japanese_article?
    self.try(:manifestation_type).try(:is_japanese_article?)
  end

  def series?
    self.try(:manifestation_type).try(:is_series?)
  end

  def non_searchable?
    return false if periodical_master
    items.each do |i|
      if !i.try(:retention_period).try(:non_searchable) and i.circulation_status.name != "Removed" and !i.non_searchable
        return false
      end
      if SystemConfiguration.get('manifestation.manage_item_rank')
        if i.rank == 0
          return false
        end
      end
    end
    true
  end

  def has_removed?
    items.each do |i|
      return true if i.circulation_status.name == "Removed" and !i.removed_at.nil?
    end
    false
  end

  def url
    #access_address
    "#{LibraryGroup.site_config.url}#{self.class.to_s.tableize}/#{self.id}"
  end

  def available_checkout_types(user)
    if user
      user.user_group.user_group_has_checkout_types.available_for_carrier_type(self.carrier_type)
    end
  end

  def new_serial?
    return false unless self.serial?    
    unless self.serial_number.blank?
      return true if self == self.series_statement.last_issue
    else
      return true if self == self.series_statement.last_issue_with_issue_number
    end
  end

  def checkout_period(user)
    if available_checkout_types(user)
      available_checkout_types(user).collect(&:checkout_period).max || 0
    end
  end

  def reservation_expired_period(user)
    if available_checkout_types(user)
      available_checkout_types(user).collect(&:reservation_expired_period).max || 0
    end
  end

  def patrons
    (creators + contributors + publishers).flatten
  end

  def set_serial_number
    if m = series_statement.try(:last_issue)
      self.original_title = m.original_title
      self.title_transcription = m.title_transcription
      self.title_alternative = m.title_alternative
      self.issn = m.issn
      unless m.serial_number_string.blank?
        self.serial_number_string = m.serial_number_string.to_i + 1
        unless m.issue_number_string.blank?
#          self.issue_number = m.issue_number.split.last.to_i + 1
          self.issue_number_string = m.issue_number_string.to_i + 1
        else
          self.issue_number_string = m.issue_number_string
        end
        self.volume_number_string = m.volume_number_string
      else
        unless m.issue_number_string.blank?
#          self.issue_number = m.issue_number.split.last.to_i + 1
#          self.issue_number_string = m.issue_number.last.to_i + 1
#          self.issue_number_string = m.issue_number_string.last.to_i + 1
          self.issue_number_string = m.issue_number_string.to_i + 1
          self.volume_number_string = m.volume_number_string
        else
          unless m.volume_number_string.blank?
#            self.volume_number = m.volume_number.split.last.to_i + 1
#            self.volume_number = m.volume_number.last.to_i + 1
#            self.volume_number_string = m.volume_number_string.last.to_i + 1
            self.volume_number_string = m.volume_number_string.to_i + 1
          end
        end
      end
    end
    self
  end

  def reservable_with_item?(user = nil)
    if SystemConfiguration.get("reserve.not_reserve_on_loan").nil?
      return true
    end
    if SystemConfiguration.get("reserve.not_reserve_on_loan")
      if user.try(:has_role?, 'Librarian')
        return true
      end
      if items.index {|item| item.available_for_reserve_with_config? }
        return true
      else
        return false
      end
    end
    return true
  end

  def reservable?
    unless SystemConfiguration.get("reserves.able_for_not_item")
      return false if items.for_checkout.empty? 
    end
    return false if self.periodical_master?
    true
  end

  def in_process?
    return true if items.map{ |i| i.shelf.try(:open_access)}.include?(9)
    false
  end

  def checkouts(start_date, end_date)
    Checkout.completed(start_date, end_date).where(:item_id => self.items.collect(&:id))
  end

  def creator(reload = false)
    creators(reload).collect(&:name).flatten
  end

  def contributor
    contributors.collect(&:name).flatten
  end

  def publisher(reload = false)
    publishers(reload).collect(&:name).flatten
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil)
    return nil if self.cached_numdocs < 5
    manifestation = nil
    # TODO: ヒット件数が0件のキーワードがあるときに指摘する
    response = Manifestation.search(:include => [:creators, :contributors, :publishers, :subjects, :items]) do
      fulltext keyword if keyword
      order_by(:random)
      paginate :page => 1, :per_page => 1
    end
    manifestation = response.results.first
  end

  def extract_text
    return nil unless attachment.path
    # TODO: S3 support
    response = `curl "#{Sunspot.config.solr.url}/update/extract?&extractOnly=true&wt=ruby" --data-binary @#{attachment.path} -H "Content-type:text/html"`
    self.fulltext = eval(response)[""]
    save(:validate => false)
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
    items.where(:shelf_id => Shelf.web.id).first
  end

  def index_series_statement
    series_statement.try(:index)
  end

  def set_series_statement
    if self.series_statement_id
      series_statement = SeriesStatement.find(self.series_statement_id)
      self.series_statement = series_statement unless series_statement.blank?   
    end
  end 
 
  def uniq_options
    self.creators.uniq!
    self.contributors.uniq!
    self.publishers.uniq!
    self.subjects.uniq!
  end

  def set_country_of_publication
    self.country_of_publication = Country.where(:name => 'Japan').first || Country.find(1) if self.country_of_publication.blank?
  end

  def last_checkout_datetime
    Manifestation.find(:last, :include => [:items, :items => :checkouts], :conditions => {:manifestations => {:id => self.id}}, :order => 'items.created_at DESC').items.first.checkouts.first.created_at rescue nil
  end

  def reserve_count(type)
    sum = 0
    case type
    when nil
    when :all
      sum = Reserve.where(:manifestation_id=>self.id).count
    when :previous_term
      term = Term.previous_term
      if term
        sum = Reserve.where("manifestation_id = ? AND created_at >= ? AND created_at <= ?", self.id, term.start_at, term.end_at).count 
      end
    when :current_term
      term = Term.current_term
      if term
        sum = Reserve.where("manifestation_id = ? AND created_at >= ? AND created_at <= ?", self.id, term.start_at, term.end_at).count 
      end
    end
    return sum
  end

  def checkout_count(type)
    sum = 0
    case type
    when nil
    when :all
      self.items.all.each {|item| sum += Checkout.where(:item_id=>item.id).count} 
    when :previous_term
      term = Term.previous_term
      if term
        self.items.all.each {|item| sum += Checkout.where("item_id = ? AND created_at >= ? AND created_at <= ?", item.id, term.start_at, term.end_at).count }
      end
    when :current_term
      term = Term.current_term
      if term
        self.items.all.each {|item| sum += Checkout.where("item_id = ? AND created_at >= ? AND created_at <= ?", item.id, term.start_at, term.end_at).count } 
      end
    end
    return sum
  end

  def next_item_for_retain(lib)
    items = self.items_ordered_for_retain(lib)
    items.each do |item|
      return item if item.available_for_checkout? && item.circulation_status != CirculationStatus.find(:first, :conditions => ["name = ?", 'Available For Pickup'])
    end
    return nil
  end

  def items_ordered_for_retain(lib = nil)
    if lib.nil?
      items = self.items
    else
      items = self.items.for_retain_from_own(lib).concat(self.items.for_retain_from_others(lib)).flatten
    end
  end
 
  def ordered?
    self.purchase_requests.each do |p|
#      return true if p.state == "ordered"
      return true if ["ordered", "accepted", "pending"].include?(p.state)
    end
    return false
  end

  def add_subject(terms)
    terms.to_s.split(';').each do |s|
      s = s.to_s.exstrip_with_full_size_space
      subject = Subject.where(:term => s).first
      unless subject
        subject = Subject.create(:term => s, :subject_type_id => 1)
      end
      self.subjects << subject unless self.subjects.include?(subject)
    end
  end

  def self.build_search_for_manifestations_list(search, query, with_filter, without_filter)
    search.build do
      fulltext query unless query.blank?
      with_filter.each do |field, op, value|
        with(field).__send__(op, value)
      end
      without_filter.each do |field, op, value|
        without(field).__send__(op, value)
      end
    end

    search
  end

  # 要求された書式で書誌リストを生成する。
  # 生成結果を構造体で返す。構造体がoutputのとき:
  #
  #  output.result_type: 生成結果のタイプ
  #    :data: データそのもの
  #    :path: データを書き込んだファイルのパス名
  #    :delayed: 後で処理する
  #  output.data: 生成結果のデータ(result_typeが:dataのとき)
  #  output.path: 生成結果のパス名(result_typeが:pathのとき)
  #  output.job_name: 後で処理する際のジョブ名(result_typeが:delayedのとき)
  def self.generate_manifestation_list(solr_search, output_type, current_user, search_condition_summary, cols=[], threshold = nil, &block)
#    get_total = proc do
#      solr_search.execute.total
#    end
    get_total = proc do
      get_periodical_master_ids = Sunspot.new_search(Manifestation).build {
          with(:periodical_master).equal_to true
          paginate :page => 1, :per_page => Manifestation.count
        }.execute.raw_results.map(&:primary_key)
      series_statements_total = Manifestation.where(:id => get_periodical_master_ids).all.inject(0) do |total, m|
          total += m.series_statement.manifestations.size
        end rescue 0
      solr_search.execute.total - get_periodical_master_ids.size + series_statements_total
    end

    get_all_ids = proc do
      solr_search.build {
        paginate :page => 1, :per_page => Manifestation.count
      }.execute.raw_results.map(&:primary_key)
    end

    threshold ||= Setting.background_job.threshold.export rescue nil
    if threshold && threshold > 0 &&
        get_total.call > threshold
      # 指定件数以上のときにはバックグラウンドジョブにする。
      user_file = UserFile.new(current_user)

      io, info = user_file.create(:manifestation_list_prepare, 'manifestation_list_prepare.tmp')
      begin
        Marshal.dump(get_all_ids.call, io)
      ensure
        io.close
      end

      job_name = GenerateManifestationListJob.generate_job_name
      Delayed::Job.enqueue GenerateManifestationListJob.new(job_name, info, output_type, current_user, search_condition_summary, cols)
      output = OpenStruct.new
      output.result_type = :delayed
      output.job_name = job_name
      block.call(output)
      return
    end

    manifestation_ids = get_all_ids.call

    generate_manifestation_list_internal(manifestation_ids, output_type, current_user, search_condition_summary, cols, &block)
  end

  def self.generate_manifestation_list_internal(manifestation_ids, output_type, current_user, search_condition_summary, cols, &block)
    output = OpenStruct.new
    output.result_type = :data

    case output_type
    when :pdf
      method = 'get_manifestation_list_pdf'
    when :tsv
      method = 'get_manifestation_list_tsv'
    when :excelx
      method = 'get_manifestation_list_excelx'
      output.result_type = :path
    when :request
      method = 'get_missing_issue_list_pdf'
    end
    filename_method = method.sub(/\Aget_(.*)(_[^_]+)\z/) { "#{$1}_print#{$2}" }
    output.filename = Setting.__send__(filename_method).filename

    if output_type == :excelx
      result = output.__send__("#{output.result_type}=",
                      self.__send__(method, manifestation_ids, current_user, cols))
    else
      manifestations = self.where(:id => manifestation_ids).all
      if output_type == :pdf
        result = output.__send__("#{output.result_type}=",
                             self.__send__(method, manifestations, current_user, search_condition_summary))
      else
        result = output.__send__("#{output.result_type}=",
                             self.__send__(method, manifestations, current_user))
      end
    end
    if output.result_type == :path
      output.path, output.data = result
    else
      output.data = /_pdf\z/ =~ method ? result.generate : result
    end
    block.call(output)
  end

  # NOTE: resource_import_textfile.excelとの整合性を維持すること
  BOOK_COLUMNS = %w(
    isbn original_title title_transcription title_alternative carrier_type
    frequency pub_date country_of_publication place_of_publication language
    edition_display_value volume_number_string issue_number_string serial_number_string lccn
    marc_number ndc start_page end_page height width depth price
    acceptance_number access_address repository_content required_role
    except_recent description supplement note creator contributor publisher
    subject accept_type acquired_at bookstore library shelf checkout_type
    circulation_status retention_period call_number item_price url
    include_supplements use_restriction item_note rank item_identifier
    remove_reason non_searchable missing_issue del_flg
  )
  SERIES_COLUMNS = %w(
    issn original_title title_transcription periodical
    series_statement_identifier note
  )
  ARTICLE_COLUMNS = %w(
    creator original_title title volume_number_string number_of_page pub_date
    call_number url subject
  )
  ALL_COLUMNS =
    BOOK_COLUMNS.map {|c| "book.#{c}" } +
    SERIES_COLUMNS.map {|c| "series.#{c}" } +
    ARTICLE_COLUMNS.map {|c| "article.#{c}" }

  def self.get_manifestation_list_excelx(manifestation_ids, current_user, selected_column = [])
    user_file = UserFile.new(current_user)
    excel_filepath, excel_fileinfo = user_file.create(:manifestation_list, Setting.manifestation_list_print_excelx.filename)

    require 'axlsx'
    pkg = Axlsx::Package.new
    wb = pkg.workbook
    sty = wb.styles.add_style :font_name => Setting.manifestation_list_print_excelx.fontname

    column = { # 書誌のタイプごとの出力すべきカラムのリスト
      'book' => [], # 一般書誌(manifestation_type.is_{series,article}?がfalse)
      'series' => SERIES_COLUMNS.map {|c| ["series", c] }, # 雑誌(manifestation_type.is_series?がtrue)
      'article' => [], # 文献(manifestation_type.is_article?がtrue)
    }
    selected_column.each do |type_col|
      next unless ALL_COLUMNS.include?(type_col)
      next unless /\A([^.]+)\.([^.]+)\z/ =~ type_col
      column[$1] << [$1, $2]
      column['series'] << [$1, $2] if $1 == 'book' # NOTE: 雑誌の行は雑誌向けカラム+一般書誌向けカラム(参照: resource_import_textfile.excel)
    end
    sheet_name = {
      'book' => 'book_list',
      'series' => 'series_list',
      'article' => 'article_list',
    }

    # 必要となりそうなワークシートの初期化
    worksheet = {}
    style = {}
    column.keys.each do |type|
      if column[type].blank?
        column.delete(type)
        next
      end
      worksheet[type] = wb.add_worksheet(:name => sheet_name[type]) do |sheet|
        row = column[type].map {|(t, c)| I18n.t("resource_import_textfile.excel.#{t}.#{c}") }
        style[type] = [sty]*row.size
        sheet.add_row row, :types => :string, :style => style[type]
      end
    end


    logger.debug "begin export manifestations"
    transaction do
      where(:id => manifestation_ids).
          includes(
            :carrier_type, :language, :required_role,
            :frequency, :creators, :contributors,
            :publishers, :subjects, :manifestation_type,
            :series_statement,
            :items => [
              :bookstore, :checkout_type,
              :circulation_status, :required_role,
              :accept_type, :retention_period,
              :use_restriction,
              :shelf => :library,
            ]
          ).
          find_in_batches do |manifestations|
        logger.debug "begin a batch set"
        manifestations.each do |manifestation|
          if manifestation.article?
            type = 'article'
            target = [manifestation]
          elsif manifestation.series?
            type = 'series'
#            target = manifestation.series_statement.manifestations # XXX: 検索結果由来とseries_statement由来とでmanifestationレコードに重複が生じる可能性があることに注意(32b51f2c以前のコードをそのまま残した) #TODO:重複はさせない
             if manifestation.periodical_master
               #target = manifestation.series_statement.manifestaitions
               target = manifestation.series_statement.manifestations.map{ |m| m unless m.periodical_master }.compact
             else 
               target = [manifestation]
             end
          else # 一般書誌
            type = 'book'
            target = [manifestation]
          end

          # 出力すべきカラムがない場合はスキップ
          next if column[type].blank?

          target.each do |m|
            if m.items.blank?
              items = [nil]
            else
              items = m.items
            end

            items.each do |i|
              row = []
              column[type].each do |(t, c)|
                row << m.excel_worksheet_value(t, c, i)
              end
              worksheet[type].add_row row, :types => :string, :style => style[type]

              # 文献をエクスポート時にはその文献情報を削除する
              # copied from app/models/resource_import_textresult.rb:92-98
              if i && type == 'article' && m.article?
                if i.reserve
                  i.reserve.revert_request rescue nil
                end
                i.destroy
              end
            end

            # 文献をエクスポート時にはその文献情報を削除する
            # copied from app/models/resource_import_textresult.rb:102-105
            if type == 'article' && m.article?
              if manifestation.items.count == 0
                manifestation.destroy
              end
            end
          end # target.each
        end # manifestations.each
        logger.debug "end a batch set"
      end # find_in_batches
    end # transaction
    logger.debug "end export manifestations"

    # 空のワークシートを削除
    #worksheet.each_pair do |type, ws|
    #  next if ws.rows.size > 1
    #  wb.worksheets.delete(ws) # 見出し行以外ない
    #end

    pkg.serialize(excel_filepath)

    [excel_filepath, excel_fileinfo]
  end

  # XLSX形式でのエクスポートのための値を生成する
  # ws_type: ワークシートの種別
  # ws_col: ワークシートでのカラム名
  # item: 対象とするItemレコード
  def excel_worksheet_value(ws_type, ws_col, item = nil)
    helper = Object.new
    helper.extend(ManifestationsHelper)
    val = nil

    case ws_col
    when 'manifestation_type'
      val = manifestation_type.try(:display_name) || ''

    when 'original_title', 'title_transcription', 'series_statement_identifier', 'periodical', 'issn', 'note'
      if ws_type == 'series'
        val = series_statement.excel_worksheet_value(ws_type, ws_col)
      end

    when 'title'
      if ws_type == 'article'
        val = article_title.to_s
      end

    when 'url'
      if ws_type == 'article'
        val = access_address.to_s
      end

    when 'volume_number_string'
      if ws_type == 'article' &&
          volume_number_string.present? && issue_number_string.present?
        val = "#{volume_number_string}*#{issue_number_string}"
      elsif volume_number_string.present?
        val = volume_number_string.to_s
      else
        val = ''
      end

    when 'number_of_page'
      if start_page.present? && end_page.present?
        val = "#{start_page}-#{end_page}"
      elsif start_page
        val = start_page.to_s
      else
        val = ''
      end

    when 'carrier_type', 'language', 'required_role'
      val = __send__(ws_col).try(:name) || ''

    when 'frequency', 'country_of_publication'
      val = __send__(ws_col).try(:display_name) || ''

    when 'creator', 'contributor', 'publisher'
      sep = ';'
      if ws_col == 'creator' &&
          ws_type == 'article' && !japanese_article?
        sep = ' '
      end
      val = __send__("#{ws_col}s").map(&:full_name).join(sep)
      if ws_col == 'creator' &&
          ws_type == 'article' && japanese_article? && !val.blank?
        val += sep
      end
    when 'subject'
      sep = ';'
      if ws_type == 'article' && !japanese_article?
        sep = '*'
      end
      val = __send__(:subjects).map(&:term).join(sep)

    when 'missing_issue'
      val = helper.missing_status(missing_issue) || ''

    when 'del_flg'
      val = '' # モデルには格納されない情報
    end
    return val unless val.nil?

    # その他の項目はitemまたはmanifestationの
    # 同名属性からそのまま転記する

    if item
      if /\Aitem_/ =~ ws_col
        begin
          val = item.excel_worksheet_value(ws_type, $') || ''
        rescue NoMethodError
        end
      end

      if val.nil?
        begin
          val = item.excel_worksheet_value(ws_type, ws_col) || ''
        rescue NoMethodError
        end
      end
    end

    if val.nil?
      begin
        val = __send__(ws_col) || ''
      rescue NoMethodError
        val = ''
      end
    end
 
    val
  end

  def self.get_missing_issue_list_pdf(manifestations, current_user)
    manifestations.each do |m|
      m.missing_issue = 2 unless m.missing_issue == 3
      m.save!(:validate => false)
    end
    get_manifestation_list_pdf(manifestations, current_user)
  end

  def self.get_manifestation_list_pdf(manifestations, current_user, search_condition_summary)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'searchlist.tlf')

    # set page_num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      page.item(:query).value(search_condition_summary)
      manifestations.each do |manifestation|
        page.list(:list).add_row do |row|
          # modified data format
          item_identifiers = manifestation.items.map{|item| item.item_identifier}
          creator = manifestation.creators.readable_by(current_user).map{|patron| patron.full_name}
          contributor = manifestation.contributors.readable_by(current_user).map{|patron| patron.full_name}
          publisher = manifestation.publishers.readable_by(current_user).map{|patron| patron.full_name}
          reserves = Reserve.waiting.where(:manifestation_id => manifestation.id, :checked_out_at => nil)
          # set list
          row.item(:title).value(manifestation.original_title)
          row.item(:item_identifier).value(item_identifiers.join(',')) unless item_identifiers.empty?
          row.item(:creator).value(creator.join(',')) unless creator.empty?
          row.item(:contributor).value(contributor.join(',')) unless contributor.empty?
          row.item(:publisher).value(publisher.join(',')) unless publisher.empty?
          row.item(:pub_date).value(manifestation.pub_date)
#          row.item(:reserves_num).value(reserves.count)
        end
      end
    end
    return report
  end

  def self.get_manifestation_list_tsv(manifestations, current_user)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    columns = [
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:item_identifier, 'activerecord.attributes.item.item_identifier'],
      [:creator, 'patron.creator'],
      [:contributor, 'patron.contributor'],
      [:publisher, 'patron.publisher'],
      [:pub_date, 'activerecord.attributes.manifestation.pub_date'],
      [:reserves_num, 'activerecord.attributes.manifestation.reserves_number']
    ]

    # title column
    row = columns.map{|column| I18n.t(column[1])}
    data << '"' + row.join("\"\t\"") +"\"\n"

    manifestations.each do |manifestation|
      row = []
      columns.each do |column|
        case column[0]
        when :title 
          row << manifestation.original_title 
        when :item_identifier
          item_identifiers = manifestation.items.map{|item| item.item_identifier}
          row << item_identifiers.join(',') rescue ''
        when :creator
          creator = manifestation.creators.readable_by(current_user).map{|patron| patron.full_name}
          row << creator.join(',') rescue ''
        when :contributor
          contributor = manifestation.contributors.readable_by(current_user).map{|patron| patron.full_name}
          row << contributor.join(',') rescue ''
        when :publisher
          publisher = manifestation.publishers.readable_by(current_user).map{|patron| patron.full_name}
          row << publisher.join(',') rescue ''
        when :pub_date
          row << manifestation.pub_date
        when :reserves_num
          row << Reserve.waiting.where(:manifestation_id => manifestation.id, :checked_out_at => nil).count rescue 0
        end
      end
      data << '"' + row.join("\"\t\"") +"\"\n"
    end
    return data
  end

  def self.get_manifestation_locate(manifestation, current_user)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'manifestation_reseat.tlf')
   
    # footer
    report.layout.config.list(:list) do
      use_stores :total => 0
      events.on :footer_insert do |e|
        e.section.item(:date).value(Time.now.strftime('%Y/%m/%d %H:%M'))
      end
    end
    # main
    report.start_new_page do |page|
      # set manifestation_information
      7.times { |i|
        label, data = "", ""
        page.list(:list).add_row do |row|
          case i
          when 0
            label = I18n.t('activerecord.attributes.manifestation.original_title')
            data  = manifestation.original_title
          when 1
            label = I18n.t('patron.creator')
            data  = manifestation.creators.readable_by(current_user).map{|patron| patron.full_name}
            data  = data.join(",")
          when 2
            label = I18n.t('patron.publisher')
            data  = manifestation.publishers.readable_by(current_user).map{|patron| patron.full_name}
            data  = data.join(",")
          when 3
            label = I18n.t('activerecord.attributes.manifestation.price')
            data  = manifestation.price
          when 4
            label = I18n.t('activerecord.attributes.manifestation.page')
            data  = manifestation.number_of_pages.to_s + 'p' if manifestation.number_of_pages
          when 5
            label = I18n.t('activerecord.attributes.manifestation.size')
            data  = manifestation.height.to_s + 'cm' if manifestation.height
          when 6
            label = I18n.t('activerecord.attributes.series_statement.original_title')
            data  = manifestation.series_statement.original_title if manifestation.series_statement
          when 7
            label = I18n.t('activerecord.attributes.manifestation.isbn')
            data  = manifestation.isbn
          end
          row.item(:label).show
          row.item(:data).show
          row.item(:dot_line).hide
          row.item(:label).value(label.to_s + ":")
          row.item(:data).value(data)
        end
      }

      # set item_information
      manifestation.items.each do |item|
        if SystemConfiguration.get('manifestation.manage_item_rank')
          if current_user.nil? or !current_user.has_role?('Librarian')
            next unless item.rank == 0
            next if item.retention_period.non_searchable
            next if item.circulation_status.name == "Removed"
            next if item.non_searchable
          end
        end
        6.times { |i|
          label, data = "", ""
          page.list(:list).add_row do |row|
            row.item(:label).show
            row.item(:data).show
            row.item(:dot_line).hide
            case i
            when 0
              row.item(:label).hide
              row.item(:data).hide
              row.item(:dot_line).show
            when 1
              label = I18n.t('activerecord.models.library')
              data  = item.shelf.library.display_name.localize
            when 2
              label = I18n.t('activerecord.models.shelf')
              data  = item.shelf.display_name.localize
            when 3
              label = I18n.t('activerecord.attributes.item.call_number')
              data  = call_numberformat(item)
            when 4
              label = I18n.t('activerecord.attributes.item.item_identifier')
              data  = item.item_identifier
            when 5
              label = I18n.t('activerecord.models.circulation_status')
              data  = item.circulation_status.display_name.localize
            end
            row.item(:label).value(label.to_s + ":")
            row.item(:data).value(data)
          end
        }
      end
    end
    return report 
  end

  class GenerateManifestationListJob
    include Rails.application.routes.url_helpers
    include BackgroundJobUtils

    def initialize(name, fileinfo, output_type, user, search_condition_summary, cols)
      @name = name
      @fileinfo = fileinfo
      @output_type = output_type
      @user = user
      @search_condition_summary = search_condition_summary
      @cols = cols
    end
    attr_accessor :name, :fileinfo, :output_type, :user, :search_condition_summary, :cols

    def perform
      user_file = UserFile.new(user)
      path, = user_file.find(fileinfo[:category], fileinfo[:filename], fileinfo[:random])
      manifestation_ids = open(path, 'r') {|io| Marshal.load(io) }

      Manifestation.generate_manifestation_list_internal(manifestation_ids, output_type, user, search_condition_summary, cols) do |output|
        io, info = user_file.create(:manifestation_list, output.filename)
        if output.result_type == :path
          open(output.path) {|io2| FileUtils.copy_stream(io2, io) }
        else
          io.print output.data
        end
        io.close

        url = my_account_url(:filename => info[:filename], :category => info[:category], :random => info[:random])
        message(
          user,
          I18n.t('manifestation.output_job_success_subject', :job_name => name),
          I18n.t('manifestation.output_job_success_body', :job_name => name, :url => url))
      end

    rescue => exception
      message(
        user,
        I18n.t('manifestation.output_job_error_subject', :job_name => name),
        #I18n.t('manifestation.output_job_error_body', :job_name => name, :message => exception.message))
        I18n.t('manifestation.output_job_error_body', :job_name => name, :message => exception.backtrace))
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
#  identifier                      :string(255)
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
#  volume_number_string              :string(255)
#  issue_number_string               :string(255)
#  serial_number_string              :string(255)
#  edition                         :integer
#  note                            :text
#  produces_count                  :integer         default(0), not null
#  exemplifies_count               :integer         default(0), not null
#  embodies_count                  :integer         default(0), not null
#  work_has_subjects_count         :integer         default(0), not null
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
#  nii_type_id                     :integer
#  title_alternative_transcription :text
#  description                     :text
#  abstract                        :text
#  available_at                    :datetime
#  valid_until                     :datetime
#  date_submitted                  :datetime
#  date_accepted                   :datetime
#  date_caputured                  :datetime
#  file_hash                       :string(255)
#  pub_date                        :string(255)
#  periodical_master               :boolean         default(FALSE), not null
#


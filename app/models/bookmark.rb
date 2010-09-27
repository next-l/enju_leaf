# -*- encoding: utf-8 -*-
class Bookmark < ActiveRecord::Base
  scope :bookmarked, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  scope :user_bookmarks, lambda {|user| {:conditions => {:user_id => user.id}}}
  belongs_to :manifestation, :class_name => 'Manifestation'
  belongs_to :user #, :counter_cache => true, :validate => true

  validates_presence_of :user, :title, :url
  validates_associated :user, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :user_id
  validates_length_of :url, :maximum => 255, :allow_blank => true
  #validate :get_manifestation
  before_validation :create_manifestation, :on => :create
  before_validation :set_url
  validate :bookmarkable_url?
  before_save :replace_space_in_tags
  after_create :create_frbr_object
  after_save :save_manifestation
  after_destroy :save_manifestation

  acts_as_taggable_on :tags
  normalize_attributes :url

  searchable do
    text :title do
      manifestation.title
    end
    string :url do
      manifestation.access_address
    end
    string :tag, :multiple => true do
      tags.collect(&:name)
    end
    integer :user_id
    integer :manifestation_id
    time :created_at
    time :updated_at
  end

  def self.per_page
    10
  end

  def set_url
    self.url = URI.parse(self.url).normalize.to_s
  rescue URI::InvalidURIError
    nil
  end

  def replace_space_in_tags
    # タグに含まれている全角スペースを除去する
    self.tag_list = self.tag_list.map{|tag| tag.gsub('　', ' ').gsub(' ', ', ')}
  end

  def save_manifestation
    self.manifestation.save
    self.manifestation.index!
  end

  def save_tagger
    #user.tag(self, :with => tag_list, :on => :tags)
    taggings.each do |tagging|
      tagging.tagger = user
      tagging.save(:validate => false)
    end
  end

  def shelved?
    true if self.manifestation.items.on_web.first
  end

  def self.get_title(string)
    CGI.unescape(string).strip unless string.nil?
  end

  def get_title
    return if url.blank?
    if url.my_host?
      my_host_resource.original_title
    else
      Bookmark.get_title_from_url(url)
    end
  end

  def self.get_title_from_url(url)
    return if url.blank?
    if manifestation_id = url.bookmarkable_id
      manifestation = Manifestation.find(manifestation_id)
      return manifestation.original_title
    end
    unless manifestation
      doc = Nokogiri::HTML(open(url))
      # TODO: 日本語以外
      #charsets = ['iso-2022-jp', 'euc-jp', 'shift_jis', 'iso-8859-1']
      #if charsets.include?(page.charset.downcase)
        title = NKF.nkf('-w', CGI.unescapeHTML((doc.at("title").inner_text))).to_s.gsub(/\r\n|\r|\n/, '').gsub(/\s+/, ' ').strip
        if title.blank?
          title = url
        end
      #else
      #  title = (doc/"title").inner_text
      #end
      title
    end
  rescue OpenURI::HTTPError
    # TODO: 404などの場合の処理
    raise "unable to access: #{url}"
  #  nil
  end

  def self.get_canonical_url(url)
    doc = Nokogiri::HTML(open(url))
    canonical_url = doc.search("/html/head/link[@rel='canonical']").first['href']
    # TODO: URLを相対指定している時
    URI.parse(canonical_url).normalize.to_s
  rescue
    nil
  end

  def my_host_resource
    if url.bookmarkable_id
      manifestation = Manifestation.find(url.bookmarkable_id)
    end
  end

  def bookmarkable_url?
    if url.try(:my_host?)
      unless url.try(:bookmarkable_id)
        errors[:base] << I18n.t('bookmark.not_our_holding')
      end
    end
  end

  def get_manifestation
    # 自館のページをブックマークする場合
    if url.try(:my_host?)
      manifestation = self.my_host_resource
    else
      if LibraryGroup.site_config.allow_bookmark_external_url
        manifestation = Manifestation.first(:conditions => {:access_address => self.url}) if self.url.present?
      end
    end
    manifestation
  end

  def create_manifestation
    manifestation = get_manifestation
    unless manifestation
      manifestation = Manifestation.new(:access_address => url)
      manifestation.carrier_type = CarrierType.first(:conditions => {:name => 'file'})
    end
    # OTC start
    # get_manifestationで自館のmanifestation以外ならば例外とし登録させないよう修正した。
    # よって、unless文の処理は不要になるはず。
    # manifestation = get_manifestationを実行するのみ。nilの場合は上で処理するので処理不要。
#    manifestation = get_manifestation
    # OTC end
    if manifestation.bookmarked?(user)
      errors[:base] << 'already_bookmarked'
    end
    if self.title.present?
      manifestation.original_title = self.title
    else
      manifestation.original_title = self.get_title
    end
    self.manifestation = manifestation
  end

  def create_frbr_object
    unless url.my_host?
      Bookmark.transaction do
        create_bookmark_item
      end
    end
  end

  def create_bookmark_item
    circulation_status = CirculationStatus.first(:conditions => {:name => 'Not Available'})
    item = Item.new(:shelf => Shelf.web, :circulation_status => circulation_status)
    manifestation.items << item
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    if manifestation
      self.bookmarked(start_date, end_date).count(:all, :conditions => {:manifestation_id => manifestation.id})
    else
      0
    end
  end

  def create_tag_index
    taggings.each do |tagging|
      Tag.find(tagging.tag_id).index!
    end
  end

end

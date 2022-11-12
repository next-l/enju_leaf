class Bookmark < ApplicationRecord
  scope :bookmarked, lambda {|start_date, end_date| where('created_at >= ? AND created_at < ?', start_date, end_date)}
  scope :user_bookmarks, lambda {|user| where(user_id: user.id)}
  scope :shared, -> {where(shared: true)}
  belongs_to :manifestation, touch: true, optional: true
  belongs_to :user

  validates :title, presence: :true
  validates :url, presence: { on: :create }
  validates :manifestation_id, presence: { on: :update }
  validates :manifestation_id, uniqueness: { scope: :user_id }
  validates :url, url: true, presence: true, length: {maximum: 255}
  validate :bookmarkable_url?
  validate :already_bookmarked?, if: :url_changed?
  before_save :create_manifestation, if: :url_changed?
  before_save :replace_space_in_tags

  acts_as_taggable_on :tags
  strip_attributes only: :url

  searchable do
    text :title do
      manifestation.title
    end
    string :url
    string :tag, multiple: true do
      tag_list
    end
    integer :user_id
    integer :manifestation_id
    time :created_at
    time :updated_at
    boolean :shared
  end

  paginates_per 10

  def replace_space_in_tags
    # タグに含まれている全角スペースを除去する
    self.tag_list = tag_list.map{|tag| tag.gsub('　', ' ').gsub(' ', ', ')}
  end

  def save_tagger
    taggings.each do |tagging|
      tagging.tagger = user
      tagging.save(validate: false)
    end
  end

  def shelved?
    true if manifestation.items.on_web.first
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
    return unless Addressable::URI.parse(url).host
    if manifestation_id = url.bookmarkable_id
      self.manifestation = Manifestation.find(manifestation_id)
      return manifestation.original_title
    end
    unless manifestation
      normalized_url = Addressable::URI.parse(url).normalize.to_s
      doc = Nokogiri::HTML(Faraday.get(normalized_url).body)
      # TODO: 日本語以外
      # charsets = ['iso-2022-jp', 'euc-jp', 'shift_jis', 'iso-8859-1']
      # if charsets.include?(page.charset.downcase)
        title = NKF.nkf('-w', CGI.unescapeHTML((doc.at("title").inner_text))).to_s.gsub(/\r\n|\r|\n/, '').gsub(/\s+/, ' ').strip
        if title.blank?
          title = url
        end
      # else
      #  title = (doc/"title").inner_text
      # end
      title
    end
  rescue OpenURI::HTTPError
    # TODO: 404などの場合の処理
    raise "unable to access: #{url}"
  #  nil
  end

  def self.get_canonical_url(url)
    doc = Nokogiri::HTML(Faraday.get(url).body)
    canonical_url = doc.search("/html/head/link[@rel='canonical']").first['href']
    # TODO: URLを相対指定している時
    Addressable::URI.parse(canonical_url).normalize.to_s
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
        errors.add(:base, I18n.t('bookmark.not_our_holding'))
      end
      unless my_host_resource
        errors.add(:base, I18n.t('bookmark.not_our_holding'))
      end
    end
  end

  def get_manifestation
    # 自館のページをブックマークする場合
    if url.try(:my_host?)
      manifestation = self.my_host_resource
    else
      manifestation = Manifestation.where(access_address: url).first if url.present?
    end
  end

  def already_bookmarked?
    if manifestation
      if manifestation.bookmarked?(user)
        errors.add(:base, 'already_bookmarked')
      end
    end
  end

  def create_manifestation
    manifestation = get_manifestation
    if manifestation
      self.manifestation_id = manifestation.id
      return
    end
    manifestation = Manifestation.new(access_address: url)
    manifestation.carrier_type = CarrierType.find_by(name: 'online_resource')
    if title.present?
      manifestation.original_title = title
    else
      manifestation.original_title = self.get_title
    end
    Manifestation.transaction do
      manifestation.save
      self.manifestation = manifestation
      item = Item.new
      item.shelf = Shelf.web
      item.manifestation = manifestation
      if defined?(EnjuCirculation)
        item.circulation_status = CirculationStatus.where(name: 'Not Available').first
      end

      item.save!
      if defined?(EnjuCirculation)
        item.use_restriction = UseRestriction.where(name: 'Not For Loan').first
      end
    end
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    if manifestation
      self.bookmarked(start_date, end_date).where(manifestation_id: manifestation.id).count
    else
      0
    end
  end

  def tag_index!
    manifestation.reload
    manifestation.index
    taggings.map{|tagging| Tag.find(tagging.tag_id).index}
    Sunspot.commit
  end
end

# == Schema Information
#
# Table name: bookmarks
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  manifestation_id :bigint
#  title            :text
#  url              :string
#  note             :text
#  shared           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

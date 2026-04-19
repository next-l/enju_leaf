class Bookmark < ApplicationRecord
  scope :bookmarked, lambda { |start_date, end_date| where("created_at >= ? AND created_at < ?", start_date, end_date) }
  scope :user_bookmarks, lambda { |user| where(user_id: user.id) }
  scope :shared, -> { where(shared: true) }
  belongs_to :manifestation, touch: true, optional: true
  belongs_to :user

  validates :title, presence: :true
  validates :manifestation_id, presence: { on: :update }, uniqueness: { scope: :user_id }
  validates :url, url: true, presence: true, length: { maximum: 255 }
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

  # @return [String]
  def replace_space_in_tags
    # タグに含まれている全角スペースを除去する
    self.tag_list = tag_list.map { |tag| tag.gsub("　", " ").gsub(" ", ", ") }
  end

  def save_tagger
    taggings.each do |tagging|
      tagging.tagger = user
      tagging.save(validate: false)
    end
  end

  # @return [Boolean]
  def shelved?
    return true if manifestation.items.on_web.first

    false
  end

  # @return [String]
  def self.get_title(string)
    CGI.unescape(string).strip unless string.nil?
  end

  # @return [String]
  def get_title
    return if url.blank?

    if url.my_host?
      my_host_resource.original_title
    else
      Bookmark.get_title_from_url(url)
    end
  end

  # @return [String]
  def get_title_from_url(url)
    return if url.blank?
    return unless Addressable::URI.parse(url).host

    if url.bookmarkable_id
      manifestation = Manifestation.find(url.bookmarkable_id)
    end
    return manifestation.original_title if manifestation

    normalized_url = Addressable::URI.parse(url).normalize.to_s
    doc = Nokogiri::HTML(Faraday.get(normalized_url).body)
      # TODO: 日本語以外
      # charsets = ['iso-2022-jp', 'euc-jp', 'shift_jis', 'iso-8859-1']
      # if charsets.include?(page.charset.downcase)
      title = NKF.nkf("-w", CGI.unescapeHTML((doc.at("title").inner_text))).to_s.gsub(/\r\n|\r|\n/, "").gsub(/\s+/, " ").strip
      if title.blank?
        title = url
      end
    # else
    #  title = (doc/"title").inner_text
    # end
    title
  rescue OpenURI::HTTPError
    # TODO: 404などの場合の処理
    raise "unable to access: #{url}"
    #  nil
  end

  def self.get_canonical_url(url)
    doc = Nokogiri::HTML(Faraday.get(url).body)
    canonical_url = doc.search("/html/head/link[@rel='canonical']").first["href"]
    # TODO: URLを相対指定している時
    Addressable::URI.parse(canonical_url).normalize.to_s
  rescue
    nil
  end

  # @return [Manifestation]
  def my_host_resource
    return unless url.bookmarkable_id

    manifestation = Manifestation.find(url.bookmarkable_id)
  end

  def bookmarkable_url?
    return false unless url.try(:my_host?)

    unless url.try(:bookmarkable_id)
      errors.add(:base, I18n.t("bookmark.not_our_holding"))
    end
    unless my_host_resource
      errors.add(:base, I18n.t("bookmark.not_our_holding"))
    end
  end

  def get_manifestation
    # 自館のページをブックマークする場合
    if url.try(:my_host?)
      manifestation = my_host_resource
    else
      manifestation = Manifestation.find_by(access_address: url) if url.present?
    end
  end

  def already_bookmarked?
    return unless manifestation

    if manifestation.bookmarked?(user)
      errors.add(:base, "already_bookmarked")
    end
  end

  # @return [Manifestation]
  def create_manifestation
    manifestation = get_manifestation
    if manifestation
      self.manifestation_id = manifestation.id
      return manifestation
    end

    manifestation = Manifestation.new(
      access_address: url,
      carrier_type: CarrierType.find_by(name: "online_resource")
    )
    if title.present?
      manifestation.original_title = title
    else
      manifestation.original_title = self.get_title
    end
    Manifestation.transaction do
      manifestation.save
      self.manifestation = manifestation
      item = Item.new(shelf: Shelf.web, manifestation: manifestation)
      if defined?(EnjuCirculation)
        item.circulation_status = CirculationStatus.where(name: "Not Available").first
      end

      item.save!
      if defined?(EnjuCirculation)
        item.use_restriction = UseRestriction.find_by(name: "Not For Loan")
      end
    end

    manifestation
  end

  # @return [Integer]
  def self.manifestations_count(start_date, end_date, manifestation)
    return 0 unless manifestation

    self.bookmarked(start_date, end_date).where(manifestation_id: manifestation.id).count
  end

  def tag_index!
    manifestation.reload
    manifestation.index
    taggings.map { |tagging| Tag.find(tagging.tag_id).index }
    Sunspot.commit
  end
end

# == Schema Information
#
# Table name: bookmarks
#
#  id               :bigint           not null, primary key
#  note             :text
#  shared           :boolean
#  title            :text
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  manifestation_id :bigint
#  user_id          :bigint           not null
#
# Indexes
#
#  index_bookmarks_on_manifestation_id  (manifestation_id)
#  index_bookmarks_on_url               (url)
#  index_bookmarks_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

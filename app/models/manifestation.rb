require EnjuTrunkFrbr::Engine.root.join('app', 'models', 'manifestation')
require EnjuTrunkCirculation::Engine.root.join('app', 'models', 'manifestation') if Setting.operation
class Manifestation < ActiveRecord::Base
  self.extend ItemsHelper
  has_many :creators, :through => :creates, :source => :patron
  has_many :contributors, :through => :realizes, :source => :patron
  has_many :publishers, :through => :produces, :source => :patron
  has_many :work_has_subjects, :foreign_key => 'work_id', :dependent => :destroy
  has_many :subjects, :through => :work_has_subjects
  has_many :reserves, :foreign_key => :manifestation_id, :order => :position
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  belongs_to :language
  belongs_to :carrier_type
  has_one :series_has_manifestation
  has_one :series_statement, :through => :series_has_manifestation
  belongs_to :frequency
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_one :resource_import_result
  has_many :purchase_requests
  has_many :table_of_contents

  belongs_to :manifestation_content_type, :class_name => 'ContentType', :foreign_key => 'content_type_id'
  belongs_to :country_of_publication, :class_name => 'Country', :foreign_key => 'country_of_publication_id'

  searchable do
    text :title, :default_boost => 2 do
      titles
    end
    text :fulltext, :note, :contributor, :description
    text :creator do
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{|manifestation| [manifestation.creator]}].flatten.compact
      else
        creator
      end
    end
    text :publisher do
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{|manifestation| [manifestation.publisher]}].flatten.compact
      else
        publisher
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
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{|manifestation| [manifestation.isbn, manifestation.isbn10, manifestation.wrong_isbn]}].flatten.compact
      else
        [isbn, isbn10, wrong_isbn]
      end
    end
    string :issn, :multiple => true do
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{|manifestation| [manifestation.issn]}].flatten.compact
      else
        issn
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
      if series_statement.try(:id) 
        1
      else
        0
      end
    end
    string :library, :multiple => true do
      items.map{|i| i.shelf.library.name}
    end
    string :language do
      language.try(:name)
    end
    string :item_identifier, :multiple => true do
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{ |manifestation| [manifestation.items.collect(&:item_identifier)] }].flatten.compact
      else
        items.collect(&:item_identifier)
      end
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
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{|manifestation| manifestation.date_of_publication}].flatten.compact
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
    integer :start_page
    integer :end_page
    integer :number_of_pages
    string :number_of_pages, :multiple => true do
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{|manifestation| manifestation.number_of_pages}].flatten.compact
      else
        number_of_pages
      end
    end
    float :price
    boolean :reservable do
      self.reservable?
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
      if series_statement.try(:periodical)  # 雑誌の場合
        series_statement.titles
      else                  # 雑誌以外（雑誌の記事も含む）
        original_manifestations.map{|m| m.title}.flatten
      end
    end
    text :isbn do  # 前方一致検索のためtext指定を追加
      if series_statement.try(:periodical)  # 雑誌の場合
        series_statement.manifestations.map{|manifestation| [manifestation.isbn, manifestation.isbn10, manifestation.wrong_isbn]}.flatten.compact
      else
        [isbn, isbn10, wrong_isbn]
      end
    end
    text :issn do  # 前方一致検索のためtext指定を追加
      if series_statement.try(:periodical)  # 雑誌の場合
        series_statement.manifestations.map{|manifestation| [manifestation.issn]}.flatten.compact
      else
        issn  
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
    string :acquired_at, :multiple => true do
      if series_statement.try(:periodical)  # 雑誌の場合
        [series_statement.manifestations.map{|manifestation| manifestation.acquired_at}].flatten.compact
      else
       acquired_at
      end
    end
    boolean :except_recent
    string :exinfo_1
    string :exinfo_2
    string :exinfo_3
    string :exinfo_4
    string :exinfo_5
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

  validates_presence_of :carrier_type, :language, :country_of_publication
  validates_associated :carrier_type, :language, :country_of_publication
  before_validation :set_language, :if => :during_import
  before_save :set_series_statement

  after_save :index_series_statement
  after_destroy :index_series_statement
  attr_accessor :during_import, :series_statement_id

  paginates_per 10

  if defined?(EnjuBookmark)
    has_many :bookmarks, :include => :tags, :dependent => :destroy, :foreign_key => :manifestation_id
    has_many :users, :through => :bookmarks

    searchable do
      string :tag, :multiple => true do
        if series_statement.try(:periodical)  # 雑誌の場合
          [series_statement.manifestations.map{ |manifestation| [manifestation.tags.collect(&:name)] }].flatten.compact
        else
          tags.collect(&:name)
        end
      end
      text :tag do
        if series_statement.try(:periodical)  # 雑誌の場合
          [series_statement.manifestations.map{ |manifestation| [manifestation.tags.collect(&:name)] }].flatten.compact
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

  def set_language
    self.language = Language.where(:name => "Japanese").first if self.language.nil?
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
          self.issue_number_string = m.issue_number_string.last.to_i + 1
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

  def checkouts(start_date, end_date)
    Checkout.completed(start_date, end_date).where(:item_id => self.items.collect(&:id))
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
      return true if p.state == "ordered"
    end
    return false
  end

private
  def self.get_manifestation_list_pdf(manifestations, current_user)
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
      manifestations.each do |manifestation|
        page.list(:list).add_row do |row|
          # modified data format
          item_identifiers = manifestation.items.map{|item| item.item_identifier}
          creator = manifestation.creators.readable_by(current_user).map{|patron| patron.full_name}
          contributor = manifestation.contributors.readable_by(current_user).map{|patron| patron.full_name}
          publisher = manifestation.publishers.readable_by(current_user).map{|patron| patron.full_name}
          # set list
          row.item(:title).value(manifestation.original_title)
          row.item(:item_identifier).value(item_identifiers.join(','))
          row.item(:creator).value(creator.join(','))
          row.item(:contributor).value(contributor.join(','))
          row.item(:publisher).value(publisher.join(','))
          row.item(:pub_date).value(manifestation.pub_date)
          row.item(:reserves_num).value(Reserve.waiting.where(:manifestation_id => manifestation.id, :checked_out_at => nil).count)
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
          row << item_identifiers.join(',')
        when :creator
          creator = manifestation.creators.readable_by(current_user).map{|patron| patron.full_name}
          row << creator.join(',')
        when :contributor
          contributor = manifestation.contributors.readable_by(current_user).map{|patron| patron.full_name}
          row << contributor.join(',')
        when :publisher
          publisher = manifestation.publishers.readable_by(current_user).map{|patron| patron.full_name}
          row << publisher.join(',')
        when :pub_date
          row << manifestation.pub_date
        when :reserves_num
          row << Reserve.waiting.where(:manifestation_id => manifestation.id, :checked_out_at => nil).count
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
          row.item(:description).hide
          row.item(:label).value(label.to_s + ":")
          row.item(:data).value(data)
        end
      }

      # set description
      if manifestation.description
        # make space
        page.list(:list).add_row do |row|
          row.item(:label).hide
          row.item(:data).hide
          row.item(:dot_line).hide
          row.item(:description).hide
        end
        # set
        max_column = 20
        cnt, str_num = 0.0, 0
        str = manifestation.description
        while str.length > max_column
          str.length.times do |i|
            cnt += 0.5 if str[i] =~ /^[\s0-9A-Za-z]+$/
            cnt += 1 unless str[i] =~ /^[\s0-9A-Za-z]+$/
            if cnt.to_f >= max_column or str[i+1].nil? or str[i] =~ /^[\n]+$/
              str_num = i + 1 if cnt.to_f == max_column or str[i+1].nil? or str[i] =~ /^[\n]+$/
              str_num = i if cnt.to_f > max_column
              page.list(:list).add_row do |row|
                row.item(:label).hide
                row.item(:data).hide
                row.item(:dot_line).hide
                row.item(:description).show
                row.item(:description).value(str[0...str_num].chomp)
              end
              str = str[str_num...str.length]
              cnt, str_num = 0.0, 0
              break
            end
          end
        end
        page.list(:list).add_row do |row|
          row.item(:label).hide
          row.item(:data).hide
          row.item(:dot_line).hide
          row.item(:description).show
          row.item(:description).value(str)
        end
      end

      # set item_information
      manifestation.items.each do |item|
        6.times { |i|
          label, data = "", ""
          page.list(:list).add_row do |row|
            row.item(:label).show
            row.item(:data).show
            row.item(:dot_line).hide
            row.item(:description).hide
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


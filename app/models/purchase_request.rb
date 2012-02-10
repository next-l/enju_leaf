class PurchaseRequest < ActiveRecord::Base
#  scope :not_ordered, includes(:order_list).where('order_lists.ordered_at IS NULL')
#  scope :ordered, includes(:order_list).where('order_lists.ordered_at IS NOT NULL')
  scope :pending, where("state = pending")
  scope :accepted, where("state = accepted")
  scope :ordered, where("state = ordered")

  belongs_to :user, :validate => true
  has_one :order, :dependent => :destroy
  has_one :order_list, :through => :order
  belongs_to :manifestation

  validates_associated :user
  validates_presence_of :user, :title
  validate :check_price
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}
  after_save :index!
  after_destroy :index!
  before_save :set_date_of_publication
  attr_protected :user
  attr_accessor :next_state, :reason

  normalize_attributes :url, :pub_date

  state_machine :initial => :pending do
    before_transition [:pending, :accepted, :rejected] => :accepted, :do => :accept
    before_transition [:pending, :rejected] => :rejected, :do => :reject    

    event :sm_accept do
      transition [:pending, :accepted, :rejected] => :accepted
    end

    event :sm_reject do
      transition [:pending, :rejected] => :rejected
    end

    event :sm_order do
      transition [:accepted] => :ordered
    end
  end

  searchable do
    text :title, :author, :publisher, :url
    string :isbn
    string :url
    integer :price
    integer :user_id
    integer :order_list_id do
      order_list.id if order_list
    end
    time :pub_date do
      date_of_publication
    end
    time :created_at
    time :accepted_at
    time :denied_at
    string :state
    boolean :ordered do
      order_list.try(:ordered_at).present? ? true : false
    end
  end

  def self.per_page
    10
  end

  def check_price
    errors.add(:price) unless self.price.nil? || self.price > 0
  end

  def accept
    self.update_attributes!(:accepted_at => Time.zone.now)
  end

  def reject
    self.update_attributes!(:denied_at => Time.zone.now)
  end
  
  def order
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

  def update_attributes_with_state(params)
    PurchaseRequest.transaction do
      self.update_attributes(params)
      case params[:next_state]
      when "accept"
        self.sm_accept!
      when "reject"
        self.sm_reject!
      end
      return true
    end
    return false
  end

  def send_message(status, reason = nil)
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    PurchaseRequest.transaction do
      case status
      when 'accepted'
        message_template = MessageTemplate.localized_template('purchase_request_accepted', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template)
        request.save_message_body(:purchase_request => Array[self], :user => self.user)
        request.sm_send_message
      when 'rejected'
        message_template = MessageTemplate.localized_template('purchase_request_rejected', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template)
        request.save_message_body(:purchase_request => Array[self], :user => self.user, :reason => reason)
        request.sm_send_message!
      else
        raise 'status to send message not defined'
      end
    end
  end

  def self.output_tsv(purchase_requests)
    @buf = String.new
    @buf << "\"" + I18n.t('activerecord.attributes.manifestation.original_title') + "\"" + "\t" +
      "\"" + I18n.t('activerecord.attributes.purchase_request.author') + "\"" + "\t" +
      "\"" + I18n.t('activerecord.attributes.purchase_request.publisher') + "\"" + "\t" +
      "\"" + I18n.t('activerecord.attributes.purchase_request.created_at') + "\"" + "\t" +
      "\"" + I18n.t('activerecord.attributes.order_list.title') + "\"" + "\t" +
      "\"" + I18n.t('activerecord.attributes.order_list.ordered_at') + "\"" + "\t" +
      "\"" + I18n.t('activerecord.attributes.order_list.bookstore') + "\"" + "\t" +
      "\n"
    purchase_requests.each do |purchase_request|
      title = purchase_request.title || ""
      author = purchase_request.author || ""
      publisher = purchase_request.publisher || ""
      created_at = purchase_request.created_at.strftime("%Y%m%d") || ""
      order_list_title = purchase_request.order_list.title rescue ""
      order_list_ordered_at = purchase_request.order_list.created_at rescue "" 
      order_list_bookstore = purchase_request.order_list.bookstore.name rescue ""
      @buf << "\"" + title + "\"" + "\t" +
              "\"" + author + "\"" + "\t" +
              "\"" + publisher + "\"" + "\t" +
              "\"" + created_at + "\"" + "\t" +
              "\"" + order_list_title + "\"" + "\t" +
              "\"" + order_list_ordered_at + "\"" + "\t" +
              "\"" + order_list_bookstore + "\"" + "\t" +
              "\n"
    end
    return @buf
  end
end

# == Schema Information
#
# Table name: purchase_requests
#
#  id                  :integer         not null, primary key
#  user_id             :integer         not null
#  title               :text            not null
#  author              :text
#  publisher           :text
#  isbn                :string(255)
#  date_of_publication :datetime
#  price               :integer
#  url                 :string(255)
#  note                :text
#  accepted_at         :datetime
#  denied_at           :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#  state               :string(255)
#  pub_date            :string(255)
#


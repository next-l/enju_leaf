class PurchaseRequest < ActiveRecord::Base
  attr_accessible :reason, :title, :author, :publisher, :isbn,
                  :date_of_publication, :price, :url, :note, :next_state, 
                  :user_id, :pub_date, :accepted_at, :manifestation_id, :denied_at

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
  #validates_presence_of :user, :title
  validates_presence_of :title
  validate :check_price
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}
  after_save :index!
  after_destroy :index!
  before_save :set_date_of_publication
  after_create :send_notice
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

  paginates_per 10

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
        if self.user
          if SystemConfiguration.get("send_message.purchase_request_accepted_for_patron")
            message_template = MessageTemplate.localized_template('purchase_request_accepted_for_patron', self.user.locale)
            request = MessageRequest.new
            request.assign_attributes({ :sender => system_user, :receiver => self.user, :message_template => message_template }, :as => :admin)
            request.save_message_body(:purchase_request => Array[self], :user => self.user)
            request.sm_send_message
          end
        end
        if SystemConfiguration.get("send_message.purchase_request_accepted_for_library")
          message_template = MessageTemplate.localized_template('purchase_request_accepted_for_library', system_user.locale)
          request = MessageRequest.new
          request.assign_attributes({ :sender => system_user, :receiver => system_user, :message_template => message_template }, :as => :admin)
          request.save_message_body(:purchase_request => Array[self])
          request.sm_send_message
        end
      when 'rejected'
        if self.user
          if SystemConfiguration.get("send_message.purchase_request_rejected")
            message_template = MessageTemplate.localized_template('purchase_request_rejected', self.user.locale)
            request = MessageRequest.new
            request.assign_attributes({ :sender => system_user, :receiver => self.user, :message_template => message_template }, :as => :admin)
            request.save_message_body(:purchase_request => Array[self], :user => self.user, :reason => reason)
            request.sm_send_message!
          end
        end
      else
        raise 'status to send message not defined'
      end
    end
    rescue Exception => e
      logger.error "Failed to send message: #{e}"
  end

  def send_notice
    MessageRequest.send_notice_to_librarians('user_create_a_purchase_request', {:purchase_request => Array[self]})
  end

  def self.get_purchase_requests_tsv(purchase_requests)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:original_title, 'activerecord.attributes.manifestation.original_title'],
      [:author, 'activerecord.attributes.purchase_request.author'],
      [:publisher, 'activerecord.attributes.purchase_request.publisher'],
      [:created_at, 'activerecord.attributes.purchase_request.created_at'],
      [:title, 'activerecord.attributes.order_list.title'],
      [:ordered_at, 'activerecord.attributes.order_list.ordered_at'],
      [:bookstore, 'activerecord.attributes.order_list.bookstore'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    purchase_requests.each do |purchase_request|
      row = []
      columns.each do |column|
        case column[0]
        when :original_title
          original_title = purchase_request.title || ""
          row << original_title
        when :author
          author = purchase_request.author || ""
          row << author
        when :publisher
          publisher = purchase_request.publisher || ""
          row << publisher
        when :created_at
          created_at = ""
          created_at = purchase_request.created_at.strftime("%Y%m%d") if purchase_request.created_at
          row << created_at
        when :title
          order_list_title = purchase_request.order_list.title rescue ""
          row << order_list_title
        when :bookstore
          order_list_bookstore = purchase_request.order_list.bookstore.name rescue ""
          row << order_list_bookstore
        end
      end
      data << '"' + row.join("\"\t\"") + "\"\n"
    end
    return data
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


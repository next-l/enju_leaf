class MessageRequest < ActiveRecord::Base
  scope :not_sent, :conditions => ['sent_at IS NULL AND state = ?', 'pending']
  scope :sent, :conditions => {:state => 'sent'}
  scope :started, :conditions => {:state => 'started'}
  belongs_to :message_template, :validate => true
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id", :validate => true
  belongs_to :receiver, :class_name => "User", :foreign_key => "receiver_id", :validate => true
  has_many :messages

  validates_associated :sender, :receiver, :message_template
  validates_presence_of :sender, :receiver, :message_template

  state_machine :initial => :pending do
    before_transition any - :sent => :sent, :do => :send_message

    event :sm_send_message do
      transition any - :sent => :sent
    end

    event :sm_start do
      transition :pending => :started
    end
  end

  def self.per_page
    10
  end

  def start_sending_message
    sm_start!
    sm_send_message!
  end

  def send_message
    message = nil
    MessageRequest.transaction do
      if self.body
        message = Message.create!(:sender => self.sender, :recipient => self.receiver.username, :subject => self.subject, :body => self.body)
      end
      self.update_attributes({:sent_at => Time.zone.now})
      Notifier.message_notification(self.receiver).deliver
      if ['reservation_expired_for_patron', 'reservation_expired_for_patron'].include?(self.message_template.status)
        self.receiver.reserves.each do |reserve|
          reserve.update_attribute(:expiration_notice_to_patron, true)
        end
      end
    end
    return message
  end
  
  def subject
    self.message_template.title
  end

  def embed_body(options = {})
    # テンプレートに実際の本文を組み込む
    # :manifestations を指定する
    message = self.message_body(options).dup
    unless message.blank?
      message = self.message_template.body.gsub('{receiver_full_name}', self.receiver.patron.full_name)
      message = message.gsub("{manifestations}", self.message_body(:manifestations => options[:manifestations]))
      message = message.gsub("{library_system_name}", LibraryGroup.site_config.display_name.localize)
    end
    self.update_attributes!({:body => message})
  end

  def message_body(options = {})
    manifestation_message = []
    manifestations = options[:manifestations]
    unless manifestations.blank?
      manifestations.each do |manifestation|
        manifestation_message << manifestation.original_title
        manifestation_message << "\r\n"
        patrons = []
        patrons << manifestation.creators
        patrons << manifestation.contributors
        patrons << manifestation.publishers
        unless patrons.flatten.blank?
          manifestation_message << "("
          manifestation_message << patrons.flatten.collect(&:full_name).join(", ")
          manifestation_message << ")"
          manifestation_message << "\r\n"
        end
        manifestation_message << "#{LibraryGroup.url}manifestations/#{manifestation.id}"
        manifestation_message << "\r\n\r\n"
      end
    end
    return manifestation_message.to_s
  end

  def self.send_messages
    count = MessageRequest.not_sent.size
    MessageRequest.not_sent.each do |request|
      request.start_sending_message
    end
    logger.info "#{Time.zone.now} sent #{count} messages!"
  end

end

class Checkin < ActiveRecord::Base
  default_scope :order => 'id DESC'
  scope :on, lambda {|date| {:conditions => ['created_at >= ? AND created_at < ?', date.beginning_of_day, date.tomorrow.beginning_of_day]}}

  has_one :checkout
  belongs_to :item
  belongs_to :librarian, :class_name => 'User'
  belongs_to :basket

  validates_presence_of :item, :basket, :on => :update
  validates_associated :item, :librarian, :basket, :on => :update
  validates_presence_of :item_identifier, :on => :create

  attr_accessor :item_identifier

  def item_checkin(current_user, escape_flag = false)
    #message = ''
    message = []
    Checkin.transaction do
      checkouts = Checkout.not_returned.where(:item_id => self.item_id).select([:id, :item_id, :lock_version])
      self.item.checkin! # unless escape_flag

      #message << I18n.t('item.this_item_include_supplement') + '<br />' if self.item.include_supplements?
      message << 'item.this_item_include_supplement' if self.item.include_supplements?

      # for item on closing shelf
      message << 'item.close_shelf' unless self.item.shelf.open? 
   
      checkouts.each do |checkout|
        # TODO: ILL時の処理
        checkout.checkin = self
        checkout.save(:validate => false)
        #message << I18n.t('checkin.other_library_item') + '<br />' unless checkout.item.shelf.library == current_user.library
        unless escape_flag
          unless checkout.item.shelf.library == current_user.library
            message << 'checkin.other_library_item'
            InterLibraryLoan.new.request_for_checkin(self.item, current_user.library)
            return
          end
        end
      end

      # checkout.user = nil unless checkout.user.save_checkout_history
      unless escape_flag
        if self.item.manifestation.next_reservation
          # TODO: もっと目立たせるために別画面を表示するべき？
          #message << I18n.t('item.this_item_is_reserved') + '<br />'
          message << 'item.this_item_is_reserved'
          self.item.retain(current_user)
        end
      end

      # メールとメッセージの送信
      #ReservationNotifier.deliver_reserved(self.item.manifestation.reserves.first.user, self.item.manifestation)
      #Message.create(:sender => current_user, :receiver => self.item.manifestation.next_reservation.user, :subject => message_template.title, :body => message_template.body, :recipient => self.item.manifestation.next_reservation.user)
    end
    if message.present?
      message
    else
      nil
    end
  end
end

# == Schema Information
#
# Table name: checkins
#
#  id           :integer         not null, primary key
#  item_id      :integer         not null
#  librarian_id :integer
#  basket_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#


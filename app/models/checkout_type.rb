class CheckoutType < ActiveRecord::Base
  default_scope :order => "checkout_types.position"
  scope :available_for_carrier_type, lambda {|carrier_type| {:include => :carrier_types, :conditions => ['carrier_types.name = ?', carrier_type.name], :order => 'carrier_types.position'}}
  scope :available_for_user_group, lambda {|user_group| {:include => :user_groups, :conditions => ['user_groups.name = ?', user_group.name], :order => 'user_group.position'}}

  has_many :user_group_has_checkout_types, :dependent => :destroy
  has_many :user_groups, :through => :user_group_has_checkout_types
  has_many :carrier_type_has_checkout_types, :dependent => :destroy
  has_many :carrier_types, :through => :carrier_type_has_checkout_types
  #has_many :item_has_checkout_types, :dependent => :destroy
  #has_many :items, :through => :item_has_checkout_types
  has_many :items

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  before_validation :set_display_name, :on => :create
  acts_as_list

  def self.per_page
    10
  end

  def set_display_name
    self.display_name = self.name if display_name.blank?
  end

end

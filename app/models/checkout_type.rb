class CheckoutType < ActiveRecord::Base
  include MasterModel
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

  def self.per_page
    10
  end
end

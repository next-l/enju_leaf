# -*- encoding: utf-8 -*-
class UserGroup < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :users
  #has_many :available_carrier_types
  #has_many :carrier_types, :through => :available_carrier_types, :order => :position
  has_many :user_group_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :user_group_has_checkout_types, :order => :position
  has_many :lending_policies

  validates_numericality_of :valid_period_for_new_user, :greater_than_or_equal_to => 0

  paginates_per 10
end

class Role < ActiveRecord::Base
  include MasterModel
  default_scope :order => "roles.position"
  has_many :user_has_roles
  has_many :users, :through => :user_has_roles

  def localized_name
    display_name.localize
  end
end

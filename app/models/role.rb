class Role < ActiveRecord::Base
  has_many :user_has_roles
  has_many :users, :through => :user_has_roles

  validates_presence_of :name

  acts_as_list

  def localized_name
    display_name.localize
  end
end

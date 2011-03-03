class Role < ActiveRecord::Base
  include MasterModel
  default_scope :order => "roles.position"
  has_many :user_has_roles
  has_many :users, :through => :user_has_roles
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  has_friendly_id :name

  def localized_name
    display_name.localize
  end

  def self.all_cache
    if Rails.env == 'production'
      Rails.cache.fetch('role_all'){Role.select(:name)}
    else
      Role.select(:name)
    end
  end
 
  def clear_all_cache
    Rails.cache.delete('role_all')
  end

  def self.default_role
    Rails.cache.fetch('default_role'){Role.find('Guest')}
  end
end

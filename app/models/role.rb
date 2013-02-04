class Role < ActiveRecord::Base
  include MasterModel
  default_scope :order => "roles.position"
  has_many :user_has_roles
  has_many :users, :through => :user_has_roles
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  has_paper_trail

  extend FriendlyId
  friendly_id :name

  def self.librarian_role_ids
     Role.where(:name => ['Administrator', 'Librarian']).select('id').inject([]) {|a, b| a << b.id}
  end

  def localized_name
    display_name.localize
  end

  def self.all_cache
    if Rails.env == 'production'
      Rails.cache.fetch('role_all'){Role.select(:name).all}
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

# == Schema Information
#
# Table name: roles
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :string(255)
#  note         :text
#  created_at   :datetime
#  updated_at   :datetime
#  score        :integer         default(0), not null
#  position     :integer
#


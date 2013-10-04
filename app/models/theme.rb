class Theme < ActiveRecord::Base
  
  acts_as_list
  default_scope :order => "position"
  attr_accessible :description, :name, :note, :position, :publish
  
  validates_presence_of :name, :position, :publish
  validates_uniqueness_of :name

  has_many :theme_has_manifestations
  has_many :manifestations, :through => :theme_has_manifestations

  PUBLISH_PATTERN = { I18n.t('resource.publish') => 0, I18n.t('resource.closed') => 1 }

  searchable do
    text :name
    time :created_at
    time :updated_at
  end

  paginates_per 10
end

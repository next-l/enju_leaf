class Theme < ActiveRecord::Base
  
  acts_as_list
  default_scope :order => "position"
  attr_accessible :description, :name, :note, :position, :publish, :manifestation, :theme_has_manifestation
  
  validates_presence_of :name, :position, :publish
  validates_uniqueness_of :name

  has_many :theme_has_manifestations, :dependent => :destroy
  has_many :manifestations, :through => :theme_has_manifestations

  PUBLISH_PATTERN = { I18n.t('resource.publish') => 0, I18n.t('resource.closed') => 1 }

  searchable do
    text :name
    time :created_at
    time :updated_at
  end
  
  def self.add_themes(theme_lists)
    return [] if theme_lists.blank?
    themes = theme_lists.split(/,/)
    list = []
    themes.uniq.compact.each_with_index do |theme, i|
      theme = theme.exstrip_with_full_size_space
      next if theme.empty?
      theme = Theme.find(:first, :conditions => ["id=?", theme])
      if theme.nil?
        theme = ThemeHasManifestation.new
        theme.theme_id = theme
        theme.save
      end
      list << theme
    end
    list
  end

  paginates_per 10
end

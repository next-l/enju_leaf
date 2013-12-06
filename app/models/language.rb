class Language < ActiveRecord::Base
  include MasterModel
  default_scope :order => "languages.position"
  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso1, :iso_639_1
  # alias_attribute :iso2, :iso_639_2
  # alias_attribute :iso3, :iso_639_3

  # Validations
  validates_presence_of :iso_639_1, :iso_639_2, :iso_639_3
  after_save :clear_available_languages_cache
  after_destroy :clear_available_languages_cache

  has_paper_trail

  def self.all_cache
    if Rails.env == 'production'
      Rails.cache.fetch('language_all'){Language.all}
    else
      Language.all
    end
  end

  def clear_available_languages_cache
    Rails.cache.delete('language_all')
    Rails.cache.delete('available_languages')
  end

  def self.available_languages
    Language.where(:iso_639_1 => I18n.available_locales.map{|l| l.to_s}).order(:position)
  end
end

# == Schema Information
#
# Table name: languages
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  native_name  :string(255)
#  display_name :text
#  iso_639_1    :string(255)
#  iso_639_2    :string(255)
#  iso_639_3    :string(255)
#  note         :text
#  position     :integer
#


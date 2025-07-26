class Country < ApplicationRecord
  include MasterModel
  default_scope { order("countries.position") }
  has_many :agents, dependent: :destroy
  has_many :libraries, dependent: :destroy
  has_one :library_group

  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso, :alpha_2
  # alias_attribute :iso3, :alpha_3
  # alias_attribute :numeric, :numeric_3

  # Validations
  validates :alpha_2, :alpha_3, :numeric_3, presence: true
  validates :name, presence: true, format: { with: /\A[0-9A-Za-z][0-9A-Za-z_\-\s,]*[0-9a-z]\Z/ }

  after_destroy :clear_all_cache
  after_save :clear_all_cache

  def self.all_cache
    Rails.cache.fetch("country_all") { Country.all.to_a }
  end

  def clear_all_cache
    Rails.cache.delete("country_all")
  end

  private

  def valid_name?
    true
  end
end

# == Schema Information
#
# Table name: countries
#
#  id           :bigint           not null, primary key
#  alpha_2      :string
#  alpha_3      :string
#  display_name :text
#  name         :string           not null
#  note         :text
#  numeric_3    :string
#  position     :integer
#
# Indexes
#
#  index_countries_on_alpha_2     (alpha_2)
#  index_countries_on_alpha_3     (alpha_3)
#  index_countries_on_lower_name  (lower((name)::text)) UNIQUE
#  index_countries_on_numeric_3   (numeric_3)
#

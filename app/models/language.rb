class Language < ApplicationRecord
  include MasterModel
  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso1, :iso_639_1
  # alias_attribute :iso2, :iso_639_2
  # alias_attribute :iso3, :iso_639_3

  # Validations
  validates :iso_639_1, presence: true # , :iso_639_2, :iso_639_3, presence: true
  validates :name, presence: true, format: { with: /\A[0-9A-Za-z][0-9A-Za-z_\-\s,]*[0-9a-z]\Z/ }

  def self.available_languages
    Language.where(iso_639_1: I18n.available_locales.map{|l| l.to_s}).order(:position)
  end

  private

  def valid_name?
    true
  end
end

# == Schema Information
#
# Table name: languages
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  native_name  :string
#  display_name :text
#  iso_639_1    :string
#  iso_639_2    :string
#  iso_639_3    :string
#  note         :text
#  position     :integer
#

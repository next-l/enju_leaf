class LibraryGroup < ApplicationRecord
  #include Singleton
  include MasterModel

  has_many :libraries, dependent: :destroy
  has_many :colors, dependent: :destroy
  belongs_to :country, optional: true
  belongs_to :user, optional: true

  validates :url, presence: true, url: true
  validates :short_name, presence: true
  validates :max_number_of_results, numericality: {
    greater_than_or_equal_to: 0
  }
  accepts_nested_attributes_for :colors, update_only: true
  accepts_nested_attributes_for :user, update_only: true
  store :settings, accessors: [
    :book_jacket_unknown_resource,
    :erms_url
  ], coder: JSON

  translates :login_banner, :footer_banner
  globalize_accessors

  has_one_attached :header_logo

  attr_accessor :delete_header_logo

  def self.site_config
    LibraryGroup.order(:created_at).first
  end

  def self.system_name(locale = I18n.locale)
    LibraryGroup.site_config.display_name.localize(locale)
  end

  def config?
    true if self == LibraryGroup.site_config
  end

  def real_libraries
    libraries.where.not(name: 'web')
  end

  def network_access_allowed?(ip_address, options = {})
    options = { network_type: :lan }.merge(options)
    client_ip = IPAddr.new(ip_address)
    case options[:network_type]
    when :admin
      allowed_networks = admin_networks.to_s.split
    else
      allowed_networks = my_networks.to_s.split
    end
    allowed_networks.each do |allowed_network|
      network = IPAddr.new(allowed_network)
      return true if network.include?(client_ip)
    rescue ArgumentError
      nil
    end

    false
  end

  def email
    user&.email
  end
end

# == Schema Information
#
# Table name: library_groups
#
#  id                            :bigint           not null, primary key
#  name                          :string           not null
#  display_name                  :text
#  short_name                    :string           not null
#  my_networks                   :text
#  old_login_banner              :text
#  note                          :text
#  country_id                    :bigint
#  position                      :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  admin_networks                :text
#  allow_bookmark_external_url   :boolean          default(FALSE), not null
#  url                           :string           default("http://localhost:3000/")
#  settings                      :text
#  html_snippet                  :text
#  book_jacket_source            :string
#  max_number_of_results         :integer          default(1000)
#  family_name_first             :boolean          default(TRUE)
#  screenshot_generator          :string
#  pub_year_facet_range_interval :integer          default(10)
#  user_id                       :bigint
#  csv_charset_conversion        :boolean          default(FALSE), not null
#  header_logo_meta              :text
#  login_banner                  :text
#  footer_banner                 :text
#

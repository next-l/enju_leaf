class LibraryGroup < ApplicationRecord
  # include Singleton
  include MasterModel

  has_many :libraries, dependent: :destroy
  has_many :colors, dependent: :destroy
  belongs_to :country, optional: true

  validates :url, presence: true, url: true
  validates :short_name, presence: true
  validates :max_number_of_results, numericality: {
    greater_than_or_equal_to: 0
  }
  accepts_nested_attributes_for :colors, update_only: true
  store_accessor :settings,
    :book_jacket_unknown_resource,
    :amazon_hostname

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
    libraries.where.not(name: "web")
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
end

# == Schema Information
#
# Table name: library_groups
#
#  id                            :bigint           not null, primary key
#  admin_networks                :text
#  allow_bookmark_external_url   :boolean          default(FALSE), not null
#  book_jacket_source            :string
#  csv_charset_conversion        :boolean          default(FALSE), not null
#  display_name                  :text
#  email                         :string
#  family_name_first             :boolean          default(TRUE)
#  footer_banner                 :text
#  html_snippet                  :text
#  login_banner                  :text
#  max_number_of_results         :integer          default(1000)
#  my_networks                   :text
#  name                          :string           not null
#  note                          :text
#  old_login_banner              :text
#  position                      :integer
#  pub_year_facet_range_interval :integer          default(10)
#  screenshot_generator          :string
#  settings                      :jsonb            not null
#  short_name                    :string           not null
#  url                           :string           default("http://localhost:3000/")
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  country_id                    :bigint
#  user_id                       :bigint
#
# Indexes
#
#  index_library_groups_on_email       (email)
#  index_library_groups_on_lower_name  (lower((name)::text)) UNIQUE
#  index_library_groups_on_short_name  (short_name)
#  index_library_groups_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

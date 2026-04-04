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
    :book_jacket_unknown_resource

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

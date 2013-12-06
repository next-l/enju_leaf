# -*- encoding: utf-8 -*-
class LibraryGroup < ActiveRecord::Base
  attr_accessible :name, :display_name, :email, :url, :login_banner, 
                  :allow_bookmark_external_url, :my_networks, :admin_networks, 
                  :use_dsbl, :dsbl_list, :note, :country_id

  #include Singleton
  #include Configurator
  include MasterModel

  has_many :libraries
  has_many :search_engines
  #has_many :news_feeds
  belongs_to :country

  validates :email, :format => {:with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i}, :presence => true
  validates :url, :presence => true, :url => true
  after_save :clear_site_config_cache

  has_paper_trail

  def clear_site_config_cache
    Rails.cache.delete('library_site_config')
  end

  def self.site_config
    #if Rails.env == 'production'
    #  Rails.cache.fetch('library_site_config'){LibraryGroup.find(1)}
    #else
      LibraryGroup.find(1)
    #end
  rescue
    nil
  end

  def self.system_name(locale = I18n.locale)
    LibraryGroup.site_config.display_name.localize(locale)
  end

  def config?
    true if self == LibraryGroup.site_config
  end

  def real_libraries
    # 物理的な図書館 = IDが1以外
    libraries.where('id != 1').all
  end

  def network_access_allowed?(ip_address, options = {})
    options = {:network_type => 'lan'}.merge(options)
    client_ip = IPAddr.new(ip_address)
    case options[:network_type]
    when 'admin'
      allowed_networks = self.admin_networks.to_s.split
    else
      allowed_networks = self.my_networks.to_s.split
    end
    allowed_networks.each do |allowed_network|
      begin
        network = IPAddr.new(allowed_network)
        return true if network.include?(client_ip)
      rescue ArgumentError
        nil
      end
    end
    return false
  end

end

# == Schema Information
#
# Table name: library_groups
#
#  id                          :integer         not null, primary key
#  name                        :string(255)     not null
#  display_name                :text
#  short_name                  :string(255)     not null
#  email                       :string(255)
#  my_networks                 :text
#  use_dsbl                    :boolean         default(FALSE), not null
#  dsbl_list                   :text
#  login_banner                :text
#  note                        :text
#  post_to_union_catalog       :boolean         default(FALSE), not null
#  country_id                  :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  admin_networks              :text
#  allow_bookmark_external_url :boolean         default(FALSE), not null
#  position                    :integer
#  url                         :string(255)     default("http://localhost:3000/")
#


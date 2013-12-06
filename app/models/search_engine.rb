class SearchEngine < ActiveRecord::Base
  default_scope :order => "position"
  belongs_to :library_group, :validate => true
  acts_as_list

  validates :name, :presence => true
  validates :query_param, :presence => true
  validates :http_method, :presence => true, :inclusion => %w(get post)
  validates :url, :presence => true, :url => true, :length => {:maximum => 255}
  validates :base_url, :presence => true, :url => true, :length => {:maximum => 255}
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  paginates_per 10

  def clear_all_cache
    Rails.cache.delete('search_engine_all')
  end

  def search_params(query)
    params = {}
    if self.additional_param
      self.additional_param.gsub('{query}', query).to_s.split.each do |param|
        p = param.split("=")
        params[p[0].to_sym] = p[1]
      end
      return params
    end
  end
end

# == Schema Information
#
# Table name: search_engines
#
#  id               :integer         not null, primary key
#  name             :string(255)     not null
#  display_name     :text
#  url              :string(255)     not null
#  base_url         :text            not null
#  http_method      :text            not null
#  query_param      :text            not null
#  additional_param :text
#  note             :text
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#


class SearchEngine < ActiveRecord::Base
  default_scope :order => "position"
  belongs_to :library_group, :validate => true
  acts_as_list

  validates_presence_of :name, :url, :base_url, :query_param, :http_method
  validates_inclusion_of :http_method, :in => %w(get post)
  validates_length_of :url, :maximum => 255
  validate :check_url
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  def self.per_page
    10
  end

  def clear_all_cache
    Rails.cache.delete('search_engine_all')
  end

  def check_url
    errors.add(:url) unless (URI(read_attribute(:url)) rescue false)
    errors.add(:base_url) unless (URI(read_attribute(:base_url)) rescue false)
  end

  def search_params(query)
    params = {}
    if self.additional_param
      self.additional_param.gsub('{query}', query).to_s.split.each do |param|
        p = param.split("=")
        params[p[0]] = p[1]
      end
      return params
    end
  end

end

class SearchEngine < ApplicationRecord
  acts_as_list

  validates :name, presence: true
  validates :query_param, presence: true
  validates :http_method, presence: true, inclusion: %w(get post)
  validates :url, presence: true, url: true, length: { maximum: 255 }
  validates :base_url, presence: true, url: true, length: { maximum: 255 }

  paginates_per 10

  def search_params(query)
    params = {}
    if additional_param
      additional_param.gsub('{query}', query).to_s.split.each do |param|
        p = param.split('=')
        params[p[0].to_sym] = p[1]
      end
      params
    end
  end
end

# == Schema Information
#
# Table name: search_engines
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  display_name     :text
#  url              :string           not null
#  base_url         :text             not null
#  http_method      :text             not null
#  query_param      :text             not null
#  additional_param :text
#  note             :text
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#

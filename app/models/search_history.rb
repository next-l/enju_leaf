class SearchHistory < ActiveRecord::Base
  scope :not_found, where(:number_of_records => 0)

  belongs_to :user
  paginates_per 10

  # http://d.hatena.ne.jp/rubyco/20070528
  def self.not_found_query(number, duration = 1.year.ago)
    self.not_found.where('created_at > ?', duration).all.collect(&:query).inject(Hash.new(0)){|r,e|r[e]+=1;r}.to_a.collect{|q| q if q[1] >= number.to_i}.compact
  end
end

# == Schema Information
#
# Table name: search_histories
#
#  id                             :integer         not null, primary key
#  user_id                        :integer
#  operation                      :string(255)     default("searchRetrieve")
#  sru_version                    :float           default(1.2)
#  query                          :string(255)
#  start_record                   :integer
#  maximum_records                :integer
#  record_packing                 :string(255)
#  record_schema                  :string(255)
#  result_set_ttl                 :integer
#  stylesheet                     :string(255)
#  extra_request_data             :string(255)
#  number_of_records              :integer         default(0)
#  result_set_id                  :string(255)
#  result_set_idle_time           :integer
#  records                        :text
#  next_record_position           :integer
#  diagnostics                    :text
#  extra_response_data            :text
#  echoed_search_retrieve_request :text
#  created_at                     :datetime
#  updated_at                     :datetime
#


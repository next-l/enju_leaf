class SearchHistory < ActiveRecord::Base
  scope :not_found, :conditions => {:number_of_records => 0}

  belongs_to :user
  def self.per_page
    10
  end

  # http://d.hatena.ne.jp/rubyco/20070528
  def self.not_found_query(number, duration = 1.year.ago)
    self.not_found.all(:conditions => ['created_at > ?', duration]).collect(&:query).inject(Hash.new(0)){|r,e|r[e]+=1;r}.to_a.collect{|q| q if q[1] >= number.to_i}.compact
  end

end

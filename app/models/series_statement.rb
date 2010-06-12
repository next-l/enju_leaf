class SeriesStatement < ActiveRecord::Base
  has_many :resources
  has_one :work
  validates_presence_of :original_title
  acts_as_list
  attr_accessor :resource_id

  searchable do
    text :title do
      original_title
    end
    text :numbering, :title_subseries, :numbering_subseries
    integer :resource_ids, :multiple => true
  end

  def last_issue
    resource = resources.first(:conditions => 'date_of_publication IS NOT NULL', :order => 'date_of_publication DESC') || resources.first
  end

end

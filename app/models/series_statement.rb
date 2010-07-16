class SeriesStatement < ActiveRecord::Base
  has_many :manifestations, :class_name => 'Resource'
  validates_presence_of :original_title
  acts_as_list

  searchable do
    text :title do
      original_title
    end
    text :numbering, :title_subseries, :numbering_subseries
    integer :manifestation_ids, :multiple => true
  end

  def last_issue
    resource = manifestations.first(:conditions => 'date_of_publication IS NOT NULL', :order => 'date_of_publication DESC') || manifestations.first
  end

end

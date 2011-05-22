class SeriesStatement < ActiveRecord::Base
  has_many :manifestations
  validates_presence_of :original_title
  validate :check_issn
  validates :issn, :format => {:with => /\d{8}/}, :allow_blank => true

  acts_as_list
  searchable do
    text :title do
      original_title
    end
    text :numbering, :title_subseries, :numbering_subseries
    integer :manifestation_ids, :multiple => true
  end

  normalize_attributes :original_title, :issn

  def last_issue
    manifestations.first(:conditions => 'date_of_publication IS NOT NULL', :order => 'date_of_publication DESC') || manifestations.first
  end

  def check_issn
    if issn.present?
      unless StdNum::ISSN.valid?(issn)
        errors.add(:issn)
      end
    end
  end
end

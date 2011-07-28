class SeriesStatement < ActiveRecord::Base
  has_many :manifestations
  validates_presence_of :original_title
  validate :check_issn
  after_create :create_initial_manifestation

  acts_as_list
  searchable do
    text :title do
      original_title
    end
    text :numbering, :title_subseries, :numbering_subseries
    integer :manifestation_ids, :multiple => true
    integer :position
    boolean :periodical
  end

  normalize_attributes :original_title, :issn

  def self.per_page
    10
  end

  def last_issue
    manifestations.first(:conditions => 'date_of_publication IS NOT NULL', :order => 'date_of_publication DESC') || manifestations.first
  end

  def check_issn
    self.issn = ISBN_Tools.cleanup(issn)
    if issn.present?
      unless StdNum::ISSN.valid?(issn)
        errors.add(:issn)
      end
    end
  end

  def create_initial_manifestation
    return nil if initial_manifestation
    return nil unless periodical
    manifestation = Manifestation.new(
      :original_title => original_title
    )
    manifestation.periodical_master = true
    self.manifestations << manifestation
  end

  def initial_manifestation
    manifestations.where(:periodical_master => true).first
  end

  def first_issue
    manifestations.order(:date_of_publication).first
  end

  def latest_issue
    manifestations.order(:date_of_publication).last
  end
end

# == Schema Information
#
# Table name: series_statements
#
#  id                          :integer         not null, primary key
#  original_title              :text
#  numbering                   :text
#  title_subseries             :text
#  numbering_subseries         :text
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  title_transcription         :text
#  title_alternative           :text
#  series_statement_identifier :string(255)
#  issn                        :string(255)
#  periodical                  :boolean
#


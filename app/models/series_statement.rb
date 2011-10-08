class SeriesStatement < ActiveRecord::Base
  has_many :series_has_manifestations, :dependent => :destroy
  has_many :manifestations, :through => :series_has_manifestations
  belongs_to :root_manifestation, :foreign_key => :root_manifestation_id, :class_name => 'Manifestation'
  validates_presence_of :original_title
  validate :check_issn
  after_save :create_root_manifestation

  acts_as_list
  searchable do
    text :title do
      titles
    end
    text :numbering, :title_subseries, :numbering_subseries
    integer :manifestation_ids, :multiple => true do
      series_has_manifestations.collect(&:manifestation_id)
    end
    integer :position
    boolean :periodical
  end

  normalize_attributes :original_title, :issn

  def self.per_page
    10
  end

  def last_issue
    manifestations.where('date_of_publication IS NOT NULL').order('date_of_publication DESC').first || manifestations.order(:id).last
  end

  def check_issn
    self.issn = ISBN_Tools.cleanup(issn)
    if issn.present?
      unless StdNum::ISSN.valid?(issn)
        errors.add(:issn)
      end
    end
  end

  def create_root_manifestation
    return nil unless periodical
    return nil if root_manifestation
    self.root_manifestation = Manifestation.new(
      :original_title => original_title
    )
  end

  def first_issue
    manifestations.order(:date_of_publication).first
  end

  def latest_issue
    manifestations.order(:date_of_publication).last
  end

  def manifestation_included(manifestation)
    series_has_manifestations.where(:manifestation_id => manifestation.id).first
  end

  def titles
    [original_title, title_transcription]
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
#  root_manifestation_id       :integer
#  note                        :text
#


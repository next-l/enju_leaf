class SeriesStatement < ApplicationRecord
  has_many :series_statement_merges, dependent: :destroy
  has_many :series_statement_merge_lists, through: :series_statement_merges
  belongs_to :manifestation, touch: true, optional: true
  belongs_to :root_manifestation, class_name: "Manifestation", touch: true, optional: true
  validates :original_title, presence: true
  validates :root_manifestation_id, uniqueness: true, allow_nil: true
  before_save :create_root_series_statement
  after_destroy :reindex
  after_save :reindex

  acts_as_list
  searchable do
    text :title do
      titles
    end
    text :numbering, :title_subseries, :numbering_subseries
    integer :manifestation_id
    integer :position
    integer :series_statement_merge_list_ids, multiple: true
  end

  attr_accessor :selected

  strip_attributes only: :original_title

  paginates_per 10

  def reindex
    manifestation.try(:index)
    root_manifestation.try(:index)
  end

  def titles
    [
      original_title,
      title_transcription
    ]
  end

  def create_root_series_statement
    if series_master?
      self.root_manifestation = manifestation
    else
      self.root_manifestation = nil
    end
  end
end

# == Schema Information
#
# Table name: series_statements
#
#  id                                 :bigint           not null, primary key
#  creator_string                     :text
#  note                               :text
#  numbering                          :text
#  numbering_subseries                :text
#  original_title                     :text
#  position                           :integer
#  series_master                      :boolean
#  series_statement_identifier        :string
#  title_alternative                  :text
#  title_subseries                    :text
#  title_subseries_transcription      :text
#  title_transcription                :text
#  volume_number_string               :text
#  volume_number_transcription_string :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  manifestation_id                   :bigint
#  root_manifestation_id              :bigint
#
# Indexes
#
#  index_series_statements_on_manifestation_id             (manifestation_id)
#  index_series_statements_on_root_manifestation_id        (root_manifestation_id)
#  index_series_statements_on_series_statement_identifier  (series_statement_identifier)
#

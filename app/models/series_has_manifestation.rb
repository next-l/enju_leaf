class SeriesHasManifestation < ActiveRecord::Base
  belongs_to :series_statement
  belongs_to :manifestation

  validates_associated :series_statement, :manifestation
  validates_presence_of :series_statement_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :series_statement_id
  after_save :reload
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :series_statement_id

  def self.per_page
    10
  end

  def reindex
    series_statement.try(:index)
    manifestation.try(:index)
  end
end

# == Schema Information
#
# Table name: series_has_manifestations
#
#  id                  :integer         not null, primary key
#  series_statement_id :integer
#  manifestation_id    :integer
#  position            :integer
#  created_at          :datetime
#  updated_at          :datetime
#


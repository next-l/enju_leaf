class SeriesHasManifestation < ActiveRecord::Base
  attr_accessible :series_statement_id, :manifestation_id
  belongs_to :series_statement
  belongs_to :manifestation
  accepts_nested_attributes_for :series_statement

  validates_associated :series_statement, :manifestation
  validates_presence_of :series_statement_id
  validates_presence_of :manifestation_id, :on => :update
  validates_uniqueness_of :manifestation_id, :scope => :series_statement_id
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :series_statement_id

  def self.per_page
    10
  end

  def reindex
    series_statement.reload; series_statement.try(:index)
    manifestation.reload; manifestation.try(:index)
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


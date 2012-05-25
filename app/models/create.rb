class Create < ActiveRecord::Base
  attr_accessible :patron_id, :work_id, :create_type_id
  belongs_to :patron
  belongs_to :work, :class_name => 'Manifestation', :foreign_key => 'work_id'
  belongs_to :create_type

  validates_associated :patron, :work
  validates_presence_of :patron_id, :work_id
  validates_uniqueness_of :work_id, :scope => :patron_id
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :work

  def self.per_page
    10
  end

  def reindex
    patron.try(:index)
    work.try(:index)
  end
end


# == Schema Information
#
# Table name: creates
#
#  id             :integer         not null, primary key
#  patron_id      :integer         not null
#  work_id        :integer         not null
#  position       :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  create_type_id :integer
#


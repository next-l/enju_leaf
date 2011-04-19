class WorkHasSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :work, :class_name => 'Manifestation'

  validates_presence_of :work, :subject #, :subject_type
  validates_associated :work, :subject
  validates_uniqueness_of :subject_id, :scope => :work_id
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :work_id

  def self.per_page
    10
  end

  def reindex
    work.index
    subject.index
  end
end

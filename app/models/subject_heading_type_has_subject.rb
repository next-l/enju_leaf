class SubjectHeadingTypeHasSubject < ActiveRecord::Base
  belongs_to :subject #, :polymorphic => true
  belongs_to :subject_heading_type

  validates_presence_of :subject, :subject_heading_type
  validates_associated :subject, :subject_heading_type
  validates_uniqueness_of :subject_id, :scope => :subject_heading_type_id

  paginates_per 10
end

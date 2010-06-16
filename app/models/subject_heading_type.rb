class SubjectHeadingType < ActiveRecord::Base
  include MasterModel
  #has_many_polymorphs :subjects, :from => [:concepts, :places], :through => :subject_heading_type_has_subjects
  has_many :subject_heading_type_has_subjects
  has_many :subjects, :through => :subject_heading_type_has_subjects
end

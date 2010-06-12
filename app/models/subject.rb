class Subject < ActiveRecord::Base
  has_many :work_has_subjects, :dependent => :destroy
  has_many :works, :through => :work_has_subjects, :class_name => 'Resource'
  belongs_to :subject_type
  has_many :subject_has_classifications, :dependent => :destroy
  has_many :classifications, :through => :subject_has_classifications
  belongs_to :subject_type, :validate => true
  has_many :subject_heading_type_has_subjects
  has_many :subject_heading_types, :through => :subject_heading_type_has_subjects
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id'

  validates_associated :subject_type
  validates_presence_of :term, :subject_type

  attr_accessor :classification_id, :subject_heading_type_id

  searchable do
    text :term
    time :created_at
    integer :required_role_id
  end
end

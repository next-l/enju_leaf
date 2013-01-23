class Subject < ActiveRecord::Base
  has_many :work_has_subjects, :dependent => :destroy
  has_many :works, :through => :work_has_subjects, :class_name => 'Manifestation'
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
    integer :work_ids, :multiple => true
    integer :classification_ids, :multiple => true
    integer :subject_heading_type_ids, :multiple => true
  end

  normalize_attributes :term

  paginates_per 10

  def self.import_subjects(subject_lists)
    list = []
    subject_lists.each do |s|
      subject = Subject.where(:term => s.to_s.strip).first
      unless subject
        # TODO: Subject typeの設定
        subject = Subject.new(
          :term => s.to_s.strip,
          :subject_type_id => 1,
        )
        subject.required_role = Role.where(:name => 'Guest').first
        subject.save
      end
      list << subject
    end
    list
  end
end

# == Schema Information
#
# Table name: subjects
#
#  id                      :integer         not null, primary key
#  parent_id               :integer
#  use_term_id             :integer
#  term                    :string(255)
#  term_transcription      :text
#  subject_type_id         :integer         not null
#  scope_note              :text
#  note                    :text
#  required_role_id        :integer         default(1), not null
#  work_has_subjects_count :integer         default(0), not null
#  lock_version            :integer         default(0), not null
#  created_at              :datetime
#  updated_at              :datetime
#  deleted_at              :datetime
#


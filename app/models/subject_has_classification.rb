class SubjectHasClassification < ActiveRecord::Base
  belongs_to :subject #, :polymorphic => true, :validate => true
  belongs_to :classification, :validate => true

  validates_associated :subject, :classification
  validates_presence_of :subject, :classification
  validates_uniqueness_of :classification_id, :scope => :subject_id

  def self.per_page
    10
  end

  #def after_save
  #  if self.subject
  #    self.subject.reload
  #    self.subject.save
  #  end
  #  if self.classification
  #    self.classification.reload
  #    self.classification.save
  #  end
  #end

  #def after_destroy
  #  after_save
  #end
end

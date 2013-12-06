require EnjuSubject::Engine.root.join('app', 'models', 'work_has_subject')
class WorkHasSubject < ActiveRecord::Base
  attr_accessible :subject_id, :work_id, :work, :subject, :position
  has_paper_trail
end

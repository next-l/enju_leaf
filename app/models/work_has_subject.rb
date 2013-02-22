require EnjuSubject::Engine.root.join('app', 'models', 'work_has_subject')
class WorkHasSubject < ActiveRecord::Base
  has_paper_trail
end

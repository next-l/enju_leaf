require EnjuSubject::Engine.root.join('app', 'models', 'subject')
class Subject < ActiveRecord::Base
  has_paper_trail

  def self.import_subjects(subject_lists)
    list = []
    subject_lists.compact.uniq.each do |s|
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

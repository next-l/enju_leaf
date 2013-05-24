# -*- encoding: utf-8 -*-
require EnjuSubject::Engine.root.join('app', 'models', 'subject')
class Subject < ActiveRecord::Base
  has_paper_trail

  def self.import_subjects(subject_lists, subject_transcriptions = nil)
    return [] if subject_lists.blank?
    subjects = subject_lists.gsub('；', ';').split(/;/)
    transcriptions = []
    if subject_transcriptions.present?
      transcriptions = subject_transcriptions.gsub('；', ';').split(/;/)
      transcriptions = transcriptions.uniq.compact
    end
    list = []
    subjects.compact.uniq.each_with_index do |s, i|
      s = s.to_s.exstrip_with_full_size_space
      next if s == ""
      subject = Subject.where(:term => s).first
      term_transcription = transcriptions[i].exstrip_with_full_size_space rescue nil
      unless subject
        # TODO: Subject typeの設定
        subject = Subject.new(
          :term => s,
          :term_transcription => term_transcription,
          :subject_type_id => 1,
        )
        subject.required_role = Role.where(:name => 'Guest').first
        subject.save
      else
        if term_transcription
          subject.term_transcription = term_transcription
          subject.save
        end
      end
      list << subject
    end
    list
  end
end

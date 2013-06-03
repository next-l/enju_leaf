# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Subject do
  fixtures :subjects

  it "should get term" do
    subjects(:subject_00001).term.should be_true
  end

  it "should get or create term" do
    subject = "件名1;test5"
    subject_transcription = "けんめいいち;てすとご"
    list = Subject.import_subjects(subject, subject_transcription)
    list[0].term.should eq "件名1"
    list[0].term_transcription.should eq "けんめいいち"
    list[1].term.should eq "test5"
    list[1].term_transcription.should eq "てすとご"
    list[1].id.should eq 5
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


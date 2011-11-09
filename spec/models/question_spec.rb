# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Question do
  fixtures :questions
  use_vcr_cassette "enju_ndl/crd", :record => :new_episodes

  it "test_should_get_crd_search" do
    result = Question.search_crd(:query_01 => 'Yahoo')
    result.should be_true
    result.total_entries.should > 0
  end

  it "should respond to last_updated_at" do
    questions(:question_00001).last_updated_at
  end
end

# == Schema Information
#
# Table name: questions
#
#  id            :integer         not null, primary key
#  user_id       :integer         not null
#  body          :text
#  shared        :boolean         default(TRUE), not null
#  answers_count :integer         default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#  deleted_at    :datetime
#  state         :string(255)
#  solved        :boolean         default(FALSE), not null
#  note          :text
#


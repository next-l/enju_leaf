# -*- encoding: utf-8 -*-
require 'rails_helper'

describe Question do
  fixtures :questions
  VCR.use_cassette "enju_ndl/crd", :record => :new_episodes do

    it "test_should_get_crd_search", :vcr => true do
      result = Question.search_crd(:query_01 => 'Yahoo')
      result.should be_truthy
      result.total_count.should > 0
    end

    it "should respond to last_updated_at" do
      questions(:question_00001).last_updated_at
    end
  end
end

# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  body          :text
#  shared        :boolean          default(TRUE), not null
#  answers_count :integer          default(0), not null
#  deleted_at    :datetime
#  state         :string
#  solved        :boolean          default(FALSE), not null
#  note          :text
#  created_at    :datetime
#  updated_at    :datetime
#

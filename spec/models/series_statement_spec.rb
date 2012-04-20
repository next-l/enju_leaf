# -*- encoding: utf-8 -*-
require 'spec_helper'

describe SeriesStatement do
  fixtures :all

  it "should create root_manifestation" do
    series_statement = FactoryGirl.create(:series_statement, :periodical => true)
    series_statement.root_manifestation.should be_true
    series_statement.manifestations.size.should eq 1
    series_statement.reload
    series_statement.root_manifestation.periodical_master?.should be_true
  end
end


# == Schema Information
#
# Table name: series_statements
#
#  id                            :integer         not null, primary key
#  original_title                :text
#  numbering                     :text
#  title_subseries               :text
#  numbering_subseries           :text
#  position                      :integer
#  created_at                    :datetime        not null
#  updated_at                    :datetime        not null
#  title_transcription           :text
#  title_alternative             :text
#  series_statement_identifier   :string(255)
#  issn                          :string(255)
#  periodical                    :boolean
#  root_manifestation_id         :integer
#  note                          :text
#  title_subseries_transcription :text
#


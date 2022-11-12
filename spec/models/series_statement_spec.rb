require 'rails_helper'

describe SeriesStatement do
  fixtures :all

  it "should create manifestation" do
    series_statement = FactoryBot.create(:series_statement)
    series_statement.root_manifestation.should be_nil
  end
end

# == Schema Information
#
# Table name: series_statements
#
#  id                                 :integer          not null, primary key
#  original_title                     :text
#  numbering                          :text
#  title_subseries                    :text
#  numbering_subseries                :text
#  position                           :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  title_transcription                :text
#  title_alternative                  :text
#  series_statement_identifier        :string
#  manifestation_id                   :integer
#  note                               :text
#  title_subseries_transcription      :text
#  creator_string                     :text
#  volume_number_string               :text
#  volume_number_transcription_string :text
#  series_master                      :boolean
#  root_manifestation_id              :integer
#

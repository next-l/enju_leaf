FactoryBot.define do
  factory :series_statement do
    sequence(:original_title){|n| "series_statement_#{n}"}
    sequence(:creator_string){|n| "シリーズの著者 #{n}" }
  end

  factory :series_statement_serial, class: SeriesStatement do
    sequence(:original_title){|n| "series_statement_serial_#{n}" }
    #f.root_manifestation_id{FactoryBot.create(:manifestation_serial).id}
    series_master{true}
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
#  created_at                         :datetime
#  updated_at                         :datetime
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

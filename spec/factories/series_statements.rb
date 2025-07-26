FactoryBot.define do
  factory :series_statement do
    sequence(:original_title) {|n| "series_statement_#{n}"}
    sequence(:creator_string) {|n| "シリーズの著者 #{n}" }
  end

  factory :series_statement_serial, class: SeriesStatement do
    sequence(:original_title) {|n| "series_statement_serial_#{n}" }
    #f.root_manifestation_id{FactoryBot.create(:manifestation_serial).id}
    series_master {true}
  end
end

# == Schema Information
#
# Table name: series_statements
#
#  id                                 :bigint           not null, primary key
#  creator_string                     :text
#  note                               :text
#  numbering                          :text
#  numbering_subseries                :text
#  original_title                     :text
#  position                           :integer
#  series_master                      :boolean
#  series_statement_identifier        :string
#  title_alternative                  :text
#  title_subseries                    :text
#  title_subseries_transcription      :text
#  title_transcription                :text
#  volume_number_string               :text
#  volume_number_transcription_string :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  manifestation_id                   :bigint
#  root_manifestation_id              :bigint
#
# Indexes
#
#  index_series_statements_on_manifestation_id             (manifestation_id)
#  index_series_statements_on_root_manifestation_id        (root_manifestation_id)
#  index_series_statements_on_series_statement_identifier  (series_statement_identifier)
#

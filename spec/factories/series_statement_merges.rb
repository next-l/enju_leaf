FactoryBot.define do
  factory :series_statement_merge do |f|
    f.series_statement_merge_list_id {FactoryBot.create(:series_statement_merge_list).id}
    f.series_statement_id {FactoryBot.create(:series_statement).id}
  end
end

# == Schema Information
#
# Table name: series_statement_merges
#
#  id                             :bigint           not null, primary key
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  series_statement_id            :bigint           not null
#  series_statement_merge_list_id :bigint           not null
#
# Indexes
#
#  index_series_statement_merges_on_list_id              (series_statement_merge_list_id)
#  index_series_statement_merges_on_series_statement_id  (series_statement_id)
#

FactoryBot.define do
  factory :series_statement_merge do |f|
    f.series_statement_merge_list_id{FactoryBot.create(:series_statement_merge_list).id}
    f.series_statement_id{FactoryBot.create(:series_statement).id}
  end
end

# == Schema Information
#
# Table name: series_statement_merges
#
#  id                             :integer          not null, primary key
#  series_statement_id            :integer          not null
#  series_statement_merge_list_id :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

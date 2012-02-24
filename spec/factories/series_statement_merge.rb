FactoryGirl.define do
  factory :series_statement_merge do |f|
    f.series_statement_merge_list_id{FactoryGirl.create(:series_statement_merge_list).id}
    f.series_statement_id{FactoryGirl.create(:series_statement).id}
  end
end

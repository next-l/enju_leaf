FactoryGirl.define do
  factory :series_statement_merge do |f|
    f.series_statement_merge_list{FactoryGirl.create(:series_statement_merge_list)}
    f.series_statement{FactoryGirl.create(:series_statement)}
  end
end

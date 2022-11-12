FactoryBot.define do
  factory :series_statement_merge_list do |f|
    f.sequence(:title){|n| "series_statement_merge_list_#{n}"}
  end
end

# == Schema Information
#
# Table name: series_statement_merge_lists
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

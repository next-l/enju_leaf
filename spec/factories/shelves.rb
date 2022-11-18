FactoryBot.define do
  factory :shelf do |f|
    f.sequence(:name){|n| "shelf_#{n}"}
    f.library_id{FactoryBot.create(:library).id}
  end
end

# == Schema Information
#
# Table name: shelves
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  library_id   :bigint           not null
#  items_count  :integer          default(0), not null
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  closed       :boolean          default(FALSE), not null
#

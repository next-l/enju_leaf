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
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  library_id   :integer          not null
#  items_count  :integer          default(0), not null
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#  closed       :boolean          default(FALSE), not null
#

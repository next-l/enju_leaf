FactoryBot.define do
  factory :library do |f|
    f.sequence(:name){|n| "library#{n}"}
    f.sequence(:short_display_name){|n| "library_#{n}"}
    f.library_group_id{LibraryGroup.first.id}
  end
end

FactoryBot.define do
  factory :invalid_library, class: Library do |f|
    f.library_group_id{LibraryGroup.first.id}
  end
end

# == Schema Information
#
# Table name: libraries
#
#  id                    :integer          not null, primary key
#  name                  :string           not null
#  display_name          :text
#  short_display_name    :string           not null
#  zip_code              :string
#  street                :text
#  locality              :text
#  region                :text
#  telephone_number_1    :string
#  telephone_number_2    :string
#  fax_number            :string
#  note                  :text
#  call_number_rows      :integer          default(1), not null
#  call_number_delimiter :string           default("|"), not null
#  library_group_id      :integer          not null
#  users_count           :integer          default(0), not null
#  position              :integer
#  country_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  deleted_at            :datetime
#  opening_hour          :text
#  isil                  :string
#  latitude              :float
#  longitude             :float
#

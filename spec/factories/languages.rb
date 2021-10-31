FactoryBot.define do
  factory :language do |f|
    f.sequence(:name){|n| "language_#{n}"}
    f.sequence(:iso_639_1){|n| "639_1_#{n}"}
    f.sequence(:iso_639_2){|n| "639_2_#{n}"}
    f.sequence(:iso_639_3){|n| "639_3_#{n}"}
  end
end

# == Schema Information
#
# Table name: languages
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  native_name  :string
#  display_name :text
#  iso_639_1    :string
#  iso_639_2    :string
#  iso_639_3    :string
#  note         :text
#  position     :integer
#

FactoryBot.define do
  factory :language do |f|
    f.sequence(:name) {|n| "language_#{n}"}
    f.sequence(:iso_639_1) {|n| "639_1_#{n}"}
    f.sequence(:iso_639_2) {|n| "639_2_#{n}"}
    f.sequence(:iso_639_3) {|n| "639_3_#{n}"}
  end
end

# == Schema Information
#
# Table name: languages
#
#  id           :bigint           not null, primary key
#  display_name :text
#  iso_639_1    :string
#  iso_639_2    :string
#  iso_639_3    :string
#  name         :string           not null
#  native_name  :string
#  note         :text
#  position     :integer
#
# Indexes
#
#  index_languages_on_iso_639_1   (iso_639_1)
#  index_languages_on_iso_639_2   (iso_639_2)
#  index_languages_on_iso_639_3   (iso_639_3)
#  index_languages_on_lower_name  (lower((name)::text)) UNIQUE
#

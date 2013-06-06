# encoding: utf-8
FactoryGirl.define do
  factory :manifestation do |f|
    f.sequence(:original_title){|n| "manifestation_title_#{n}"}
    f.carrier_type_id{CarrierType.find(1).id}
    f.manifestation_type_id {ManifestationType.first.try(:id) || FactoryGirl.create(:manifestation_type).id}
  end
  factory :m_with_creator, :class => 'Manifestation' do |f|
    f.sequence(:original_title){|n| "manifestation_title_#{n}"}
    f.creator{"著者1;著者2"}
    f.creator_transcription{"ちょしゃいち;ちょしゃに"}
    f.carrier_type_id{CarrierType.find(1).id}
    f.manifestation_type_id {ManifestationType.first.try(:id) || FactoryGirl.create(:manifestation_type).id}
  end
  factory :m_with_contributor, :class => 'Manifestation' do |f|
    f.sequence(:original_title){|n| "manifestation_title_#{n}"}
    f.contributor{"編者;協力者"}
    f.contributor_transcription{"へんじゃ;きょうりょくしゃ"}
    f.carrier_type_id{CarrierType.find(1).id}
    f.manifestation_type_id {ManifestationType.first.try(:id) || FactoryGirl.create(:manifestation_type).id}
  end
  factory :m_with_publisher, :class => 'Manifestation' do |f|
    f.sequence(:original_title){|n| "manifestation_title_#{n}"}
    f.publisher{"出版者1;出版者2"}
    f.publisher_transcription{"しゅっぱんしゃいち;しゅっぱんしゃに"}
    f.carrier_type_id{CarrierType.find(1).id}
    f.manifestation_type_id {ManifestationType.first.try(:id) || FactoryGirl.create(:manifestation_type).id}
  end
  factory :m_with_subject, :class => 'Manifestation' do |f|
    f.sequence(:original_title){|n| "manifestation_title_#{n}"}
    f.subject{"件名1;件名2"}
    f.subject_transcription{"けんめいいち;けんめいに"}
    f.carrier_type_id{CarrierType.find(1).id}
    f.manifestation_type_id {ManifestationType.first.try(:id) || FactoryGirl.create(:manifestation_type).id}
  end
end

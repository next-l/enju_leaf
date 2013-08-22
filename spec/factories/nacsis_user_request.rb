# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :nacsis_user_request do
    sequence :subject_heading do |n| "本表題/責任表示#{n}" end
    sequence :publisher do |n| "出版者#{n}" end
    sequence :pub_date do |n| "出版年#{n}" end
    sequence :physical_description do |n| "形態(ページ情報)#{n}" end
    sequence :series_title do |n| "シリーズ名#{n}" end
    sequence :note do |n| "資料注記#{n}" end
    sequence :isbn do |n| "ISBN#{n}" end
    sequence :pub_country do |n| "出版国#{n}" end
    sequence :title_language do |n| "標題言語#{n}" end
    sequence :text_language do |n| "本文言語#{n}" end
    sequence :classmark do |n| "分類記号#{n}" end
    sequence :author_heading do |n| "著者情報#{n}" end
    sequence :subject do |n| "件名#{n}" end
    sequence :ncid do |n| "NCID#{n}" end
    sequence :user_note do |n| "利用者注記#{n}" end
    sequence :librarian_note do |n| "事務員注記#{n}" end
    request_type 1
    state 1
    association :user, :factory => :librarian
  end
end

require 'rails_helper'

RSpec.describe 'Page', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Librarian' do
    before do
      sign_in users(:librarian1)
    end

    it 'should show index' do
      visit root_path(locale: :ja)
      expect(page).to have_content 'ようこそ'
    end
  end

  describe 'When logged in as User' do
    before do
      sign_in users(:user1)
    end

    it 'should show index' do
      visit root_path(locale: :ja)
      expect(page).to have_content 'ようこそ'
    end
  end

  describe 'When not logged in' do
    it 'should show index' do
      visit root_path(locale: :ja)
      expect(page).to have_content '資料の検索'
    end
  end
end

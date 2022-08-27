require 'rails_helper'

RSpec.describe 'Bookmarks', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Librarian' do
    it 'should get new bookmark' do
      sign_in users(:librarian1)
      visit new_bookmark_path('bookmark[title]': 'ブックマークのテスト')

      expect(page).to have_field('bookmark_title', with: 'ブックマークのテスト')
    end
  end
end

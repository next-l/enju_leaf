require 'rails_helper'

RSpec.describe 'Baskets', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Librarian' do
    it 'should contain checkout item' do
      sign_in users(:librarian1)
      visit new_basket_path
      fill_in :basket_user_number, with: '00003'
      click_on '読み込み'

      fill_in :checked_item_item_identifier, with: '00011'
      click_on '読み込み'
     
      expect(page).to have_content 'よくわかる最新Webサービス技術の基本と仕組み : 標準Webシステム技術とeコマース基盤技術入門'
    end
  end
end

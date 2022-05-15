require 'rails_helper'

RSpec.describe 'Checkins', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Librarian' do
    it 'should contain checkin item' do
      sign_in users(:librarian1)
      visit new_checkin_path

      fill_in :checkin_item_identifier, with: '00011'
      click_on '返却（取り消しはできません）'
     
      expect(page).to have_content 'よくわかる最新Webサービス技術の基本と仕組み : 標準Webシステム技術とeコマース基盤技術入門'
    end
  end
end

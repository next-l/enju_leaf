require 'rails_helper'

RSpec.describe 'Checkouts', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  before(:each) do
    CarrierType.find_by(name: 'volume').attachment.attach(io: File.open("#{Rails.root.to_s}/app/assets/images/icons/book.png"), filename: 'book.png')
  end

  describe 'When logged in as Librarian' do
    it 'should contain query params in the facet' do
      sign_in users(:librarian1)
      visit checkout_path(checkouts(:checkout_00001))
      expect(page).to have_content '利用者番号'
      expect(page).to have_content checkouts(:checkout_00001).user.username
      expect(page).to have_content checkouts(:checkout_00001).user.profile.user_number
    end

    it 'should edit checkout' do
      sign_in users(:librarian1)
      visit edit_checkout_path(checkouts(:checkout_00001))
      expect(page).to have_content '貸出の表示'
    end

    it 'should get checkouts with item_id' do
      sign_in users(:librarian1)
      visit checkouts_path(item_id: 1)
      expect(page).to have_content checkouts(:checkout_00001).user.username
      expect(page).to have_content checkouts(:checkout_00001).user.profile.user_number
    end
  end

  describe 'When not logged in', solr: true do
    before(:each) do
      Checkout.reindex
    end

    it 'should contain query params in the facet' do
      sign_in users(:librarian1)
      visit checkouts_path(days_overdue: 10)
      expect(page).to have_link 'RSS', href: checkouts_path(format: :rss, days_overdue: 10)
      expect(page).to have_link 'TSV', href: checkouts_path(format: :txt, days_overdue: 10, locale: 'ja')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Reserves', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Librarian' do
    before(:each) do
      sign_in users(:librarian1)
    end

    it 'should contain user information' do
      visit reserves_path(format: :text)
      expect(page).to have_content reserves(:reserve_00001).user.username
      expect(page).to have_content reserves(:reserve_00001).manifestation.original_title
    end

    it 'should set default library' do
      visit new_reserve_path(user_id: users(:user2))
      expect(page).to have_select('reserve[pickup_location_id]', selected: 'Hachioji Library')
    end
  end
end

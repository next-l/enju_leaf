require 'rails_helper'

RSpec.describe 'Reserves', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Librarian' do
    it 'should contain user information' do
      sign_in users(:librarian1)
      visit reserves_path(format: :text)
      expect(page).to have_content reserves(:reserve_00001).user.username
      expect(page).to have_content reserves(:reserve_00001).manifestation.original_title
    end
  end
end

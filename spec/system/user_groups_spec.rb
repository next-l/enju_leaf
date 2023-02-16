require 'rails_helper'

RSpec.describe 'UserGroup', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Admin' do
    it 'should render' do
      sign_in users(:admin)
      visit user_group_path(user_groups(:user_group_00001))
      expect(page).to have_content 'not specified'
    end
  end
end

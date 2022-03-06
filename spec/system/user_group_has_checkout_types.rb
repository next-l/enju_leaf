require 'rails_helper'

RSpec.describe 'UserGroupHasCheckoutType', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all

  describe 'When logged in as Librarian' do
    it 'should render' do
      sign_in users(:librarian1)
      visit edit_user_group_has_checkout_path(user_group_has_checkout_types(:user_group_has_checkout_type_00001))
      expect(page).to have_field :user_group_id
    end
  end
end

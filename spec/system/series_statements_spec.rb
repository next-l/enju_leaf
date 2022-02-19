require 'rails_helper'

RSpec.describe 'SeriesStatements', type: :system do
  include Devise::Test::IntegrationHelpers
  fixtures :all
  before do
    @series_statement = FactoryBot.create(:series_statement)
  end

  describe 'When not logged in' do
    it 'should show default series_statement' do
      visit series_statement_path(@series_statement.id, locale: :ja)
      expect(page).to have_content @series_statement.creator_string
    end
  end
end

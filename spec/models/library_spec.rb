require 'rails_helper'

describe Library do
  fixtures :all

  before(:each) do
    @library = FactoryBot.create(:library)
  end

  it "should should create default shelf" do
    @library.shelves.first.should be_truthy
    @library.shelves.first.name.should eq "#{@library.name}_default"
  end
end

# == Schema Information
#
# Table name: libraries
#
#  id                    :bigint           not null, primary key
#  call_number_delimiter :string           default("|"), not null
#  call_number_rows      :integer          default(1), not null
#  display_name          :text
#  fax_number            :string
#  isil                  :string
#  latitude              :float
#  locality              :text
#  longitude             :float
#  name                  :string           not null
#  note                  :text
#  opening_hour          :text
#  position              :integer
#  region                :text
#  short_display_name    :string           not null
#  street                :text
#  telephone_number_1    :string
#  telephone_number_2    :string
#  users_count           :integer          default(0), not null
#  zip_code              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  country_id            :bigint
#  library_group_id      :bigint           not null
#
# Indexes
#
#  index_libraries_on_isil              (isil) UNIQUE WHERE (((isil)::text <> ''::text) AND (isil IS NOT NULL))
#  index_libraries_on_library_group_id  (library_group_id)
#  index_libraries_on_lower_name        (lower((name)::text)) UNIQUE
#  index_libraries_on_name              (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (library_group_id => library_groups.id)
#

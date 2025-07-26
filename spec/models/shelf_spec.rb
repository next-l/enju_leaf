require 'rails_helper'

describe Shelf do
  fixtures :all

  it "should respond to web_shelf" do
    shelves(:shelf_00001).web_shelf?.should be_truthy
    shelves(:shelf_00002).web_shelf?.should_not be_truthy
  end
end

# == Schema Information
#
# Table name: shelves
#
#  id           :bigint           not null, primary key
#  closed       :boolean          default(FALSE), not null
#  display_name :text
#  items_count  :integer          default(0), not null
#  name         :string           not null
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  library_id   :bigint           not null
#
# Indexes
#
#  index_shelves_on_library_id  (library_id)
#  index_shelves_on_lower_name  (lower((name)::text)) UNIQUE
#

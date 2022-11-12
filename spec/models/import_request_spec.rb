require 'rails_helper'

describe ImportRequest do
  fixtures :all

  context "import" do
    it "should import bibliographic record", vcr: true do
      old_count = Manifestation.count
      import_request = ImportRequest.create(isbn: '9784797350999')
      import_request.import!
      Manifestation.count.should eq old_count + 1
    end
  end
end

# == Schema Information
#
# Table name: import_requests
#
#  id               :bigint           not null, primary key
#  isbn             :string
#  manifestation_id :bigint
#  user_id          :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

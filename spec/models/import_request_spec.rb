require 'rails_helper'

describe ImportRequest do
  fixtures :all

  context "import" do
    it "should import bibliographic record", vcr: true do
      old_count = Manifestation.count
      import_request = ImportRequest.create(isbn: '9784797350999')
      import_request.import!
      expect(Manifestation.count).to eq old_count + 1

      expect(import_request.manifestation.original_title).to eq "暗号技術入門 : 秘密の国のアリス"
      expect(import_request.manifestation.creators.order(:created_at).first.ndla_record.body).to eq "http://id.ndl.go.jp/auth/entity/00325825"
    end

    it "should not import author that has the same identifier", vcr: true do
      import_request1 = ImportRequest.create(isbn: '9784797350999')
      import_request1.import!
      import_request2 = ImportRequest.create(isbn: '9784815621353')
      import_request2.import!

      expect(NdlaRecord.where(body: "http://id.ndl.go.jp/auth/entity/00325825").count).to eq 1
      expect(NdlaRecord.find_by(body: "http://id.ndl.go.jp/auth/entity/00325825").agent.works.count).to eq 2
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

require 'rails_helper'
 
describe ResourceExportFile do
  fixtures :all
  
  it "should export ncid" do
    manifestation = FactoryBot.create(:manifestation)
    type = IdentifierType.find_or_create_by(name: "ncid")
    identifier = FactoryBot.create(:identifier, identifier_type: type, body: "a11223344")
    manifestation.identifiers << identifier
    export_file = ResourceExportFile.new
    export_file.user = users(:admin)
    export_file.save!
    export_file.export!
    CSV.parse(export_file.attachment.download, headers: true, col_sep: "\t").each do |row|
      expect(row).to have_key "library"
      expect(row).to have_key "shelf"
      expect(row).to have_key "ncid"
      if row['manifestation_id'] == identifier.manifestation_id
        expect(row["ncid"]).to eq identifier.body
      end
    end
  end
end

# == Schema Information
#
# Table name: resource_export_files
#
#  id          :bigint           not null, primary key
#  executed_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

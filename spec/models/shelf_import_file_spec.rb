require 'rails_helper'

RSpec.describe ShelfImportFile, type: :model do
  xit "should import rows" do
    ShelfImportFile.import
  end
end

# == Schema Information
#
# Table name: shelf_import_files
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

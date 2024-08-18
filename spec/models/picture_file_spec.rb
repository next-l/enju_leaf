require 'rails_helper'

describe PictureFile do
  fixtures :all

  it "should move position" do
    picture_file = PictureFile.find(1)
    expect(picture_file.first?).to be_truthy
    picture_file.move_lower
    expect(picture_file.last?).to be_truthy
  end
end

# == Schema Information
#
# Table name: picture_files
#
#  id                      :bigint           not null, primary key
#  picture_attachable_id   :bigint
#  picture_attachable_type :string
#  title                   :text
#  position                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  picture_file_name       :string
#  picture_content_type    :string
#  picture_file_size       :integer
#  picture_updated_at      :datetime
#  picture_fingerprint     :string
#  picture_width           :integer
#  picture_height          :integer
#

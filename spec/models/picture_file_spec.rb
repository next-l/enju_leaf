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
#  picture_attachable_type :string
#  picture_content_type    :string
#  picture_file_name       :string
#  picture_file_size       :integer
#  picture_fingerprint     :string
#  picture_height          :integer
#  picture_updated_at      :datetime
#  picture_width           :integer
#  position                :integer
#  title                   :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  picture_attachable_id   :bigint
#
# Indexes
#
#  index_picture_files_on_picture_attachable_id_and_type  (picture_attachable_id,picture_attachable_type)
#

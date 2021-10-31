require 'rails_helper'

describe PictureFile do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: picture_files
#
#  id                      :integer          not null, primary key
#  picture_attachable_id   :integer
#  picture_attachable_type :string
#  title                   :text
#  position                :integer
#  created_at              :datetime
#  updated_at              :datetime
#  picture_file_name       :string
#  picture_content_type    :string
#  picture_file_size       :integer
#  picture_updated_at      :datetime
#  picture_meta            :text
#  picture_fingerprint     :string
#  picture_width           :integer
#  picture_height          :integer
#

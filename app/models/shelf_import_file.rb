class ShelfImportFile < ApplicationRecord
  belongs_to :user
  has_one_attached :attachment
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

class PictureFile < ApplicationRecord
  scope :attached, -> { where.not(picture_attachable_id: nil) }
  belongs_to :picture_attachable, polymorphic: true

  has_one_attached :attachment

  validates :picture_attachable_type, presence: true, inclusion: { in: ['Event', 'Manifestation', 'Agent', 'Shelf'] }
  validates_associated :picture_attachable
  default_scope { order('picture_files.position') }
  # http://railsforum.com/viewtopic.php?id=11615
  acts_as_list scope: :picture_attachable
  strip_attributes only: :picture_attachable_type

  paginates_per 10
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
#  picture_meta            :text
#  picture_fingerprint     :string
#  picture_width           :integer
#  picture_height          :integer
#

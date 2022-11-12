class CarrierType < ApplicationRecord
  include MasterModel
  include EnjuCirculation::EnjuCarrierType
  has_many :manifestations, dependent: :restrict_with_exception
  if ENV['ENJU_STORAGE'] == 's3'
    has_attached_file :attachment, storage: :s3,
      styles: { thumb: "16x16#" },
      s3_credentials: {
        access_key: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_NAME'],
        s3_host_name: ENV['S3_HOST_NAME'],
        s3_region: ENV['S3_REGION']
      },
      s3_permissions: :private
  else
    has_attached_file :attachment,
      styles: { thumb: "16x16#" },
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\Z/

  before_save do
    attachment.clear if delete_attachment == '1'
  end

  attr_accessor :delete_attachment

  def mods_type
    case name
    when 'volume'
      'text'
    else
      # TODO: その他のタイプ
      'software, multimedia'
    end
  end
end

# == Schema Information
#
# Table name: carrier_types
#
#  id                      :bigint           not null, primary key
#  name                    :string           not null
#  display_name            :text
#  note                    :text
#  position                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :bigint
#  attachment_updated_at   :datetime
#

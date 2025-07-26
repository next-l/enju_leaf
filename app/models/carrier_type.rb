class CarrierType < ApplicationRecord
  include MasterModel
  include EnjuCirculation::EnjuCarrierType
  has_many :manifestations, dependent: :restrict_with_exception
  has_one_attached :attachment

  before_save do
    attachment.purge if delete_attachment == "1"
  end

  attr_accessor :delete_attachment

  def mods_type
    case name
    when "volume"
      "text"
    else
      # TODO: その他のタイプ
      "software, multimedia"
    end
  end
end

# ## Schema Information
#
# Table name: `carrier_types`
#
# ### Columns
#
# Name                           | Type               | Attributes
# ------------------------------ | ------------------ | ---------------------------
# **`id`**                       | `bigint`           | `not null, primary key`
# **`attachment_content_type`**  | `string`           |
# **`attachment_file_name`**     | `string`           |
# **`attachment_file_size`**     | `bigint`           |
# **`attachment_updated_at`**    | `datetime`         |
# **`display_name`**             | `text`             |
# **`name`**                     | `string`           | `not null`
# **`note`**                     | `text`             |
# **`position`**                 | `integer`          |
# **`created_at`**               | `datetime`         | `not null`
# **`updated_at`**               | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_carrier_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#

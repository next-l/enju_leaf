class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :lockable
  include EnjuSeed::EnjuUser
  include EnjuCirculation::EnjuUser
  include EnjuMessage::EnjuUser
  include EnjuBookmark::EnjuUser
  include EnjuPurchaseRequest::EnjuUser
end

# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`confirmed_at`**            | `datetime`         |
# **`email`**                   | `string`           | `default(""), not null`
# **`encrypted_password`**      | `string`           | `default(""), not null`
# **`expired_at`**              | `datetime`         |
# **`failed_attempts`**         | `integer`          | `default(0)`
# **`locked_at`**               | `datetime`         |
# **`remember_created_at`**     | `datetime`         |
# **`reset_password_sent_at`**  | `datetime`         |
# **`reset_password_token`**    | `string`           |
# **`unlock_token`**            | `string`           |
# **`username`**                | `string`           |
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`profile_id`**              | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_users_on_email`:
#     * **`email`**
# * `index_users_on_profile_id`:
#     * **`profile_id`**
# * `index_users_on_reset_password_token` (_unique_):
#     * **`reset_password_token`**
# * `index_users_on_unlock_token` (_unique_):
#     * **`unlock_token`**
# * `index_users_on_username` (_unique_):
#     * **`username`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`profile_id => profiles.id`**
#

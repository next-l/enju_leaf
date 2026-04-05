FactoryBot.define do
  factory :message do
    recipient { 'user1' }
    association :sender, factory: :user
    subject { 'new message' }
    body { 'new message body is really short' }
  end
end

# ## Schema Information
#
# Table name: `messages`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`body`**                | `text`             |
# **`depth`**               | `integer`          |
# **`lft`**                 | `integer`          |
# **`read_at`**             | `datetime`         |
# **`rgt`**                 | `integer`          |
# **`subject`**             | `string`           | `not null`
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
# **`message_request_id`**  | `bigint`           |
# **`parent_id`**           | `bigint`           |
# **`receiver_id`**         | `bigint`           |
# **`sender_id`**           | `bigint`           |
#
# ### Indexes
#
# * `index_messages_on_message_request_id`:
#     * **`message_request_id`**
# * `index_messages_on_parent_id`:
#     * **`parent_id`**
# * `index_messages_on_receiver_id`:
#     * **`receiver_id`**
# * `index_messages_on_sender_id`:
#     * **`sender_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`parent_id => messages.id`**
#

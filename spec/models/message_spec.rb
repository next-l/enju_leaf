require 'rails_helper'

describe Message do
  fixtures :all

  before(:each) do
    @message = FactoryBot.create(:message)
  end

  it 'should require body' do
    expect(@message.errors[:body]).to be_truthy
  end

  it 'should require recipient' do
    expect(@message.errors[:recipient]).to be_truthy
  end

  it 'should require subject' do
    expect(@message.errors[:subject]).to be_truthy
  end

  it 'should return sender_name' do
    expect(@message.sender.username).to be_truthy
  end

  it 'should return receiver_name' do
    @message.receiver = users(:user1)
    expect(@message.receiver.username).to be_truthy
  end

  it 'should set read_at' do
    message = messages(:user2_to_user1_1)
    message.transition_to!(:read)
    expect(message.read_at).to be_truthy
    expect(message.read?).to be_truthy
    expect(message.current_state).to eq 'read'
  end

  it 'should require valid recipient' do
    @message.recipient = 'invalidusername'
    expect(@message.save).to be_falsy
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

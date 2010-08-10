require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  fixtures :users, :messages

  def test_should_require_body
    m = create_message(:body => nil)
    assert m.errors[:body]
  end

  def test_should_require_recipient
    m = create_message(:recipient => nil)
    assert m.errors[:recipient]
  end
  
  def test_should_require_subject
    m = create_message(:subject => nil)
    assert m.errors[:subject]
  end
  
  def test_should_return_sender_name
    m = create_message
    assert_not_nil m.sender.username
  end
  
  def test_should_return_receiver_name
    m = create_message
    m.receiver = users(:user1)
    assert_not_nil m.receiver.username
  end
  
  def test_should_set_read_at
    m = messages(:user2_to_user1_1)
    m.sm_read!
    assert m.read_at
    assert m.read?
    assert_equal m.state, 'read'
  end
  
  protected
  def create_message(options = {})
    Message.create({ :recipient => users(:user1).username, :sender => users(:user2), :subject => 'new message', :body => 'new message body is really short' }.merge(options))
  end
end

class MessageStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :unread
  state :read

  transition from: :pending, to: :unread
  transition from: :pending, to: :read
  transition from: :unread, to: :read
  transition from: :read, to: :unread

  before_transition(from: :pending, to: :read) do |message|
    message.read_at = Time.zone.now unless message.read_at
  end

  before_transition(from: :unread, to: :read) do |message|
    message.read_at = Time.zone.now unless message.read_at
  end

  before_transition(from: :read, to: :unread) do |message|
    message.read_at = nil
  end

  after_transition(from: :pending, to: :read) do |message|
    message.index
    Sunspot.commit
  end

  after_transition(from: :unread, to: :read) do |message|
    message.index
    Sunspot.commit
  end

  after_transition(from: :read, to: :unread) do |message|
    message.index
    Sunspot.commit
  end
end

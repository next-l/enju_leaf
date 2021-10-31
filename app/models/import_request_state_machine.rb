class ImportRequestStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :completed
  state :failed

  transition from: :pending, to: [:completed, :failed]
end

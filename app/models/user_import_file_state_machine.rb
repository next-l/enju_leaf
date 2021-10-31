class UserImportFileStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :started
  state :completed
  state :failed

  transition from: :pending, to: [:started, :failed]
  transition from: :started, to: [:completed, :failed]

  after_transition(from: :pending, to: :started) do |user_import_file|
    user_import_file.update_column(:executed_at, Time.zone.now)
  end

  before_transition(from: :started, to: :completed) do |user_import_file|
    user_import_file.error_message = nil
  end
end

class UserExportFileStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :started
  state :completed
  state :failed

  transition from: :pending, to: :started
  transition from: :started, to: [:completed, :failed]

  after_transition(from: :pending, to: :started) do |user_export_file|
    user_export_file.update_column(:executed_at, Time.zone.now)
  end
end

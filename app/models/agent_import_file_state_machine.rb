class AgentImportFileStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :started
  state :completed
  state :failed

  transition from: :pending, to: [:started, :failed]
  transition from: :started, to: [:completed, :failed]

  after_transition(from: :pending, to: :started) do |agent_import_file|
    agent_import_file.update_column(:executed_at, Time.zone.now)
  end

  before_transition(from: :started, to: :completed) do |agent_import_file|
    agent_import_file.error_message = nil
  end
end

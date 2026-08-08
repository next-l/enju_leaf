class ManifestationReserveStatStateMachine
  include Statesman::Machine
  state :pending, initial: true
  state :started
  state :completed

  transition from: :pending, to: :started
  transition from: :started, to: :completed

  after_transition(to: :started) do |manifestation_reserve_stat|
    manifestation_reserve_stat.calculate_count!
  end
end

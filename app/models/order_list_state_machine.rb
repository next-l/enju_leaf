class OrderListStateMachine
  include Statesman::Machine
  state :pending, initial: true
  state :not_ordered
  state :ordered

  transition from: :pending, to: :not_ordered
  transition from: :pending, to: :ordered
  transition from: :not_ordered, to: :ordered

  before_transition(to: :ordered) do |order_list|
    order_list.order
  end
end

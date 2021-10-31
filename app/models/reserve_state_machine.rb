class ReserveStateMachine
  include Statesman::Machine
  state :pending, initial: true
  state :postponed
  state :requested
  state :retained
  state :canceled
  state :expired
  state :completed

  transition from: :pending, to: [:requested]
  transition from: :postponed, to: [:requested, :retained, :canceled, :expired]
  transition from: :retained, to: [:postponed, :canceled, :expired, :completed]
  transition from: :requested, to: [:retained, :canceled, :expired, :completed]

  after_transition(to: :requested) do |reserve|
    reserve.update(request_status_type: RequestStatusType.find_by(name: 'In Process'), item_id: nil, retained_at: nil)
  end

  after_transition(to: :retained) do |reserve|
    # TODO: 「取り置き中」の状態を正しく表す
    reserve.update(request_status_type: RequestStatusType.find_by(name: 'In Process'), retained_at: Time.zone.now)
    Reserve.transaction do
      if reserve.item
        other_reserves = reserve.item.reserves.waiting
        other_reserves.each{|r|
          if r != reserve
            r.transition_to!(:postponed)
            r.item = nil
            r.save!
          end
        }
      end
    end
  end

  after_transition(to: :canceled) do |reserve|
    Reserve.transaction do
      reserve.update(request_status_type: RequestStatusType.find_by(name: 'Cannot Fulfill Request'), canceled_at: Time.zone.now)
      next_reserve = reserve.next_reservation
      if next_reserve
        next_reserve.item = reserve.item
        reserve.item = nil
        reserve.save!
        next_reserve.transition_to!(:retained)
      end
    end
  end

  after_transition(to: :expired) do |reserve|
    Reserve.transaction do
      reserve.update(request_status_type: RequestStatusType.find_by(name: 'Expired'), canceled_at: Time.zone.now)
      next_reserve = reserve.next_reservation
      if next_reserve
        next_reserve.item = reserve.item
        next_reserve.transition_to!(:retained)
        reserve.item = nil
        reserve.save!
      end
    end
    Rails.logger.info "#{Time.zone.now} reserve_id #{reserve.id} expired!"
  end

  after_transition(to: :postponed) do |reserve|
    reserve.update(item_id: nil, retained_at: nil, postponed_at: Time.zone.now, force_retaining: "1")
  end

  after_transition(to: :completed) do |reserve|
    reserve.update(
      request_status_type: RequestStatusType.find_by(name: 'Available For Pickup'),
      checked_out_at: Time.zone.now
    )
  end

  after_transition(to: :requested) do |reserve|
    reserve.send_message
  end

  after_transition(to: :expired) do |reserve|
    reserve.send_message
  end

  after_transition(to: :postponed) do |reserve|
    reserve.send_message
  end

  after_transition(to: :canceled) do |reserve|
    reserve.send_message
  end

  after_transition(to: :retained) do |reserve|
    reserve.send_message
  end
end

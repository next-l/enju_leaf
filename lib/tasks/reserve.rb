def update_reserve
  Reserve.find_each do |reserve|
    ReserveTransition.first_or_create(reserve_id: 1, sort_key: 0, to_state: reserve.state)
  end
end

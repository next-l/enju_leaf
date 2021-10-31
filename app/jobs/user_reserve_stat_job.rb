class UserReserveStatJob < ApplicationJob
  queue_as :enju_leaf

  def perform(user_reserve_stat)
    user_reserve_stat.transition_to!(:started)
  end
end

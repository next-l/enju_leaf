class UserCheckoutStatJob < ApplicationJob
  queue_as :enju_leaf

  def perform(user_checkout_stat)
    user_checkout_stat.transition_to!(:started)
  end
end

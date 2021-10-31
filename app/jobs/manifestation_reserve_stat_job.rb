class ManifestationReserveStatJob < ApplicationJob
  queue_as :enju_leaf

  def perform(manifestation_reserve_stat)
    manifestation_reserve_stat.transition_to!(:started)
  end
end

module EnjuEvent
  module Controller

    private

    def get_event
      if params[:event_id]
        @event = Event.find(params[:event_id])
        authorize @event, :show?
      end
    end
  end
end

module CheckoutsHelper
  def filtered_params
    params.permit([:user_id, :days_overdue, :reserved])
  end
end

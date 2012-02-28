class BudgetTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @budget_type = BudgetType.find(params[:id])
    if params[:move]
      move_position(@budget_type, params[:move])
      return
    end
    update!
  end
end

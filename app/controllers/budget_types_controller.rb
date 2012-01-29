class BudgetTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @budget_type = BudgetType.find(params[:id])
    if params[:position]
      @budget_type.insert_at(params[:position])
      redirect_to budget_types_url
      return
    end
    update!
  end
end

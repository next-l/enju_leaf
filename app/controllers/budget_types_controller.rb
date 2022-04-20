class BudgetTypesController < ApplicationController
  before_action :set_budget_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /budget_types
  def index
    @budget_types = BudgetType.order(:position)
  end

  # GET /budget_types/1
  def show
  end

  # GET /budget_types/new
  def new
    @budget_type = BudgetType.new
  end

  # GET /budget_types/1/edit
  def edit
  end

  # POST /budget_types
  def create
    @budget_type = BudgetType.new(budget_type_params)

    respond_to do |format|
      if @budget_type.save
        format.html { redirect_to @budget_type, notice: t('controller.successfully_created', model: t('activerecord.models.budget_type')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /budget_types/1
  def update
    if params[:move]
      move_position(@budget_type, params[:move])
      return
    end

    respond_to do |format|
      if @budget_type.update(budget_type_params)
        format.html { redirect_to @budget_type, notice: t('controller.successfully_updated', model: t('activerecord.models.budget_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /budget_types/1
  def destroy
    @budget_type.destroy

    respond_to do |format|
      format.html { redirect_to budget_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.budget_type')) }
    end
  end

  private

  def set_budget_type
    @budget_type = BudgetType.find(params[:id])
    authorize @budget_type
  end

  def check_policy
    authorize BudgetType
  end

  def budget_type_params
    params.require(:budget_type).permit(
      :name, :display_name, :note, :position
    )
  end
end

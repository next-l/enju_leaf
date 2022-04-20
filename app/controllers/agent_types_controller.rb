class AgentTypesController < ApplicationController
  before_action :set_agent_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /agent_types
  def index
    @agent_types = AgentType.order(:position)
  end

  # GET /agent_types/1
  def show
  end

  # GET /agent_types/new
  def new
    @agent_type = AgentType.new
  end

  # GET /agent_types/1/edit
  def edit
  end

  # POST /agent_types
  def create
    @agent_type = AgentType.new(agent_type_params)

    respond_to do |format|
      if @agent_type.save
        format.html { redirect_to @agent_type, notice: t('controller.successfully_created', model: t('activerecord.models.agent_type')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /agent_types/1
  def update
    if params[:move]
      move_position(@agent_type, params[:move])
      return
    end

    respond_to do |format|
      if @agent_type.update(agent_type_params)
        format.html { redirect_to @agent_type, notice: t('controller.successfully_updated', model: t('activerecord.models.agent_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /agent_types/1
  def destroy
    @agent_type.destroy

    respond_to do |format|
      format.html { redirect_to agent_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.agent_type')) }
    end
  end

  private
  def set_agent_type
    @agent_type = AgentType.find(params[:id])
    authorize @agent_type
  end

  def check_policy
    authorize AgentType
  end

  def agent_type_params
    params.require(:agent_type).permit(:name, :display_name, :note)
  end
end

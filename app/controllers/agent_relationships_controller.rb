class AgentRelationshipsController < ApplicationController
  before_action :set_agent_relationship, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_agent
  before_action :prepare_options, only: [:new, :edit]

  # GET /agent_relationships
  # GET /agent_relationships.json
  def index
    case
    when @agent
      @agent_relationships = @agent.agent_relationships.order('agent_relationships.position').page(params[:page])
    else
      @agent_relationships = AgentRelationship.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /agent_relationships/1
  # GET /agent_relationships/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /agent_relationships/new
  def new
    if @agent.blank?
      redirect_to agents_url
      nil
    else
      @agent_relationship = AgentRelationship.new
      @agent_relationship.agent = @agent
    end
  end

  # GET /agent_relationships/1/edit
  def edit
  end

  # POST /agent_relationships
  # POST /agent_relationships.json
  def create
    @agent_relationship = AgentRelationship.new(agent_relationship_params)

    respond_to do |format|
      if @agent_relationship.save
        format.html { redirect_to @agent_relationship, notice: t('controller.successfully_created', model: t('activerecord.models.agent_relationship')) }
        format.json { render json: @agent_relationship, status: :created, location: @agent_relationship }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @agent_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /agent_relationships/1
  # PUT /agent_relationships/1.json
  def update
    # 並べ替え
    if @agent && params[:move]
      move_position(@agent_relationship, params[:move], false)
      redirect_to agent_relationships_url(agent_id: @agent_relationship.parent_id)
      return
    end

    respond_to do |format|
      if @agent_relationship.update(agent_relationship_params)
        format.html { redirect_to @agent_relationship, notice: t('controller.successfully_updated', model: t('activerecord.models.agent_relationship')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @agent_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agent_relationships/1
  # DELETE /agent_relationships/1.json
  def destroy
    @agent_relationship.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.agent_relationship'))
        if @agent
          redirect_to agents_url(agent_id: @agent.id)
        else
          redirect_to agent_relationships_url
        end
      }
      format.json { head :no_content }
    end
  end

  private
  def set_agent_relationship
    @agent_relationship = AgentRelationship.find(params[:id])
    authorize @agent_relationship
  end

  def check_policy
    authorize AgentRelationship
  end

  def agent_relationship_params
    params.require(:agent_relationship).permit(
      :parent_id, :child_id, :agent_relationship_type_id
    )
  end

  def prepare_options
    @agent_relationship_types = AgentRelationshipType.all
  end
end

class AgentMergesController < ApplicationController
  before_action :set_agent_merge, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_agent, :get_agent_merge_list

  # GET /agent_merges
  # GET /agent_merges.json
  def index
    if @agent
      @agent_merges = @agent.agent_merges.order('agent_merges.id').page(params[:page])
    elsif @agent_merge_list
      @agent_merges = @agent_merge_list.agent_merges.order('agent_merges.id').includes(:agent).page(params[:page])
    else
      @agent_merges = AgentMerge.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /agent_merges/1
  # GET /agent_merges/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /agent_merges/new
  # GET /agent_merges/new.json
  def new
    @agent_merge = AgentMerge.new
    @agent_merge.agent = @agent
  end

  # GET /agent_merges/1/edit
  def edit
  end

  # POST /agent_merges
  # POST /agent_merges.json
  def create
    @agent_merge = AgentMerge.new(agent_merge_params)

    respond_to do |format|
      if @agent_merge.save
        format.html { redirect_to(@agent_merge, notice: t('controller.successfully_created', model: t('activerecord.models.agent_merge'))) }
        format.json { render json: @agent_merge, status: :created, location: @agent_merge }
      else
        format.html { render action: "new" }
        format.json { render json: @agent_merge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /agent_merges/1
  # PUT /agent_merges/1.json
  def update
    respond_to do |format|
      if @agent_merge.update(agent_merge_params)
        format.html { redirect_to(@agent_merge, notice: t('controller.successfully_updated', model: t('activerecord.models.agent_merge'))) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @agent_merge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agent_merges/1
  # DELETE /agent_merges/1.json
  def destroy
    @agent_merge.destroy

    respond_to do |format|
      format.html { redirect_to(agent_merges_url) }
      format.json { head :no_content }
    end
  end

  private
  def set_agent_merge
    @agent_merge = AgentMerge.find(params[:id])
    authorize @agent_merge
  end

  def check_policy
    authorize AgentMerge
  end

  def agent_merge_params
    params.require(:agent_merge).permit(:agent_id, :agent_merge_list_id)
  end
end

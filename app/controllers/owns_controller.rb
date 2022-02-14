class OwnsController < ApplicationController
  before_action :set_own, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_agent, :get_item

  # GET /owns
  # GET /owns.json
  def index
    if @agent
      @owns = @agent.owns.order('owns.position').page(params[:page])
    elsif @item
      @owns = @item.owns.order('owns.position').page(params[:page])
    else
      @owns = Own.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @owns }
    end
  end

  # GET /owns/1
  # GET /owns/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @own }
    end
  end

  # GET /owns/new
  def new
    if @item && @agent.blank?
      redirect_to item_agents_url(@item)
      nil
    elsif @agent && @item.blank?
      redirect_to agent_items_url(@agent)
      nil
    else
      @own = Own.new
      @own.item = @item
      @own.agent = @agent
    end
  end

  # GET /owns/1/edit
  def edit
  end

  # POST /owns
  # POST /owns.json
  def create
    @own = Own.new(own_params)

    respond_to do |format|
      if @own.save
        format.html { redirect_to @own, notice: t('controller.successfully_created', model: t('activerecord.models.own')) }
        format.json { render json: @own, status: :created, location: @own }
      else
        format.html { render action: "new" }
        format.json { render json: @own.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /owns/1
  # PUT /owns/1.json
  def update
    if @item && params[:move]
      move_position(@own, params[:move], false)
      redirect_to owns_url(item_id: @own.item_id)
      return
    end

    respond_to do |format|
      if @own.update(own_params)
        format.html { redirect_to @own, notice: t('controller.successfully_updated', model: t('activerecord.models.own')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @own.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /owns/1
  # DELETE /owns/1.json
  def destroy
    @own.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.own'))
        case
        when @agent
          redirect_to agent_owns_url(@agent)
        when @item
          redirect_to item_owns_url(@item)
        else
          redirect_to owns_url
        end
      }
      format.json { head :no_content }
    end
  end

  private
  def set_own
    @own = Own.find(params[:id])
    authorize @own
  end

  def check_policy
    authorize Own
  end

  def own_params
    params.require(:own).permit(:agent_id, :item_id)
  end
end

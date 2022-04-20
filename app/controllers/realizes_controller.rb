class RealizesController < ApplicationController
  before_action :set_realize, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_agent, :get_expression
  before_action :prepare_options, only: [:new, :edit]

  # GET /realizes
  def index
    case
    when @agent
      @realizes = @agent.realizes.order('realizes.position').page(params[:page])
    when @expression
      @realizes = @expression.realizes.order('realizes.position').page(params[:page])
    else
      @realizes = Realize.page(params[:page])
    end
  end

  # GET /realizes/1
  def show
  end

  # GET /realizes/new
  def new
    if @expression && @agent.blank?
      redirect_to expression_agents_url(@expression)
      nil
    elsif @agent && @expression.blank?
      redirect_to agent_expressions_url(@agent)
      nil
    else
      @realize = Realize.new
      @realize.expression = @expression
      @realize.agent = @agent
    end
  end

  # GET /realizes/1/edit
  def edit
  end

  # POST /realizes
  def create
    @realize = Realize.new(realize_params)

    respond_to do |format|
      if @realize.save
        format.html { redirect_to @realize, notice: t('controller.successfully_created', model: t('activerecord.models.realize')) }
      else
        prepare_options
        format.html { render action: "new" }
      end
    end
  end

  # PUT /realizes/1
  def update
    # 並べ替え
    if @expression && params[:move]
      move_position(@realize, params[:move], false)
      redirect_to realizes_url(expression_id: @realize.expression_id)
      return
    end

    respond_to do |format|
      if @realize.update(realize_params)
        format.html { redirect_to @realize, notice: t('controller.successfully_updated', model: t('activerecord.models.realize')) }
      else
        prepare_options
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /realizes/1
  def destroy
    @realize.destroy

    flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.realize'))
    case
    when @expression
      redirect_to expression_agents_url(@expression)
    when @agent
      redirect_to agent_expressions_url(@agent)
    else
      redirect_to realizes_url
    end
  end

  private
  def set_realize
    @realize = Realize.find(params[:id])
    authorize @realize
  end

  def check_policy
    authorize Realize
  end

  def realize_params
    params.require(:realize).permit(
      :agent_id, :expression_id, :realize_type_id, :position
    )
  end

  def prepare_options
    @realize_types = RealizeType.all
  end
end

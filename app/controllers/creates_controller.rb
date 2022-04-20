class CreatesController < ApplicationController
  before_action :set_create, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_agent, :get_work
  before_action :prepare_options, only: [:new, :edit]

  # GET /creates
  def index
    case
    when @agent
      @creates = @agent.creates.order('creates.position').page(params[:page])
    when @work
      @creates = @work.creates.order('creates.position').page(params[:page])
    else
      @creates = Create.page(params[:page])
    end
  end

  # GET /creates/1
  def show
  end

  # GET /creates/new
  def new
    if @agent && @work.blank?
      redirect_to agent_works_url(@patorn)
    elsif @work && @agent.blank?
      redirect_to work_agents_url(@work)
    else
      @create = Create.new
      @create.work = @work
      @create.agent = @agent
    end
  end

  # GET /creates/1/edit
  def edit
  end

  # POST /creates
  def create
    @create = Create.new(create_params)

    respond_to do |format|
      if @create.save
        format.html { redirect_to @create, notice: t('controller.successfully_created', model: t('activerecord.models.create')) }
      else
        prepare_options
        format.html { render action: "new" }
      end
    end
  end

  # PUT /creates/1
  def update
    # 並べ替え
    if @work && params[:move]
      move_position(@create, params[:move], false)
      redirect_to creates_url(work_id: @create.work_id)
      return
    end

    respond_to do |format|
      if @create.update(create_params)
        format.html { redirect_to @create, notice: t('controller.successfully_updated', model: t('activerecord.models.create')) }
      else
        prepare_options
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /creates/1
  def destroy
    @create.destroy

    flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.create'))
    case
    when @agent
      redirect_to agent_works_url(@agent)
    when @work
      redirect_to work_agents_url(@work)
    else
      redirect_to creates_url
    end
  end

  private
  def set_create
    @create = Create.find(params[:id])
    authorize @create
  end

  def check_policy
    authorize Create
  end

  def create_params
    params.require(:create).permit(
      :agent_id, :work_id, :create_type_id, :position
    )
  end

  def prepare_options
    @create_types = CreateType.all
  end
end

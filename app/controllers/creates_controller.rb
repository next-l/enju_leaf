class CreatesController < ApplicationController
  before_action :set_create, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_agent, :get_work
  before_action :prepare_options, only: [:new, :edit]

  # GET /creates
  # GET /creates.json
  def index
    case
    when @agent
      @creates = @agent.creates.order('creates.position').page(params[:page])
    when @work
      @creates = @work.creates.order('creates.position').page(params[:page])
    else
      @creates = Create.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @creates }
    end
  end

  # GET /creates/1
  # GET /creates/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @create }
    end
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
  # POST /creates.json
  def create
    @create = Create.new(create_params)

    respond_to do |format|
      if @create.save
        format.html { redirect_to @create, notice: t('controller.successfully_created', model: t('activerecord.models.create')) }
        format.json { render json: @create, status: :created, location: @create }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @create.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /creates/1
  # PUT /creates/1.json
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
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @create.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /creates/1
  # DELETE /creates/1.json
  def destroy
    @create.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.create'))
      case
      when @agent
        format.html { redirect_to agent_works_url(@agent) }
        format.json { head :no_content }
      when @work
        format.html { redirect_to work_agents_url(@work) }
        format.json { head :no_content }
      else
        format.html { redirect_to creates_url }
        format.json { head :no_content }
      end
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

class SubscribesController < ApplicationController
  before_action :set_subscribe, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_subscription, :get_work

  # GET /subscribes
  # GET /subscribes.json
  def index
    @subscribes = Subscribe.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subscribes }
    end
  end

  # GET /subscribes/1
  # GET /subscribes/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subscribe }
    end
  end

  # GET /subscribes/new
  # GET /subscribes/new.json
  def new
    @subscribe = Subscribe.new
    @subscribe.subscription = @subscription if @subscription
    @subscribe.work = @work if @work

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subscribe }
    end
  end

  # GET /subscribes/1/edit
  def edit
  end

  # POST /subscribes
  # POST /subscribes.json
  def create
    @subscribe = Subscribe.new(subscribe_params)

    respond_to do |format|
      if @subscribe.save
        format.html { redirect_to @subscribe, notice: t('controller.successfully_created', model: t('activerecord.models.subscribe')) }
        format.json { render json: @subscribe, status: :created, location:  @subscribe }
      else
        format.html { render action: "new" }
        format.json { render json: @subscribe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subscribes/1
  # PUT /subscribes/1.json
  def update
    respond_to do |format|
      if @subscribe.update(subscribe_params)
        format.html { redirect_to @subscribe, notice: t('controller.successfully_updated', model: t('activerecord.models.subscribe')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subscribe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscribes/1
  # DELETE /subscribes/1.json
  def destroy
    @subscribe.destroy

    respond_to do |format|
      format.html { redirect_to subscribes_url }
      format.json { head :no_content }
    end
  end

  private

  def set_subscribe
    @subscribe = Subscribe.find(params[:id])
    authorize @subscribe
  end

  def check_policy
    authorize Subscribe
  end

  def subscribe_params
    params.require(:subscribe).permit(
      :subscription_id, :work_id, :start_at, :end_at
    )
  end
end

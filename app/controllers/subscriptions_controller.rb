class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_work

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    if @work
      @subscriptions = @work.subscriptions.page(params[:page])
    else
      @subscriptions = Subscription.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subscriptions }
    end
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subscription }
    end
  end

  # GET /subscriptions/new
  # GET /subscriptions/new.json
  def new
    @subscription = Subscription.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subscription }
    end
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(subscription_params)
    @subscription.user = current_user

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to @subscription, notice: t('controller.successfully_created', model: t('activerecord.models.subscription')) }
        format.json { render json: @subscription, status: :created, location: @subscription }
      else
        format.html { render action: "new" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subscriptions/1
  # PUT /subscriptions/1.json
  def update
    @subscription.assign_attributes(subscription_params)
    respond_to do |format|
      if @subscription.save
        format.html { redirect_to @subscription, notice: t('controller.successfully_updated', model: t('activerecord.models.subscription')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to subscriptions_url }
      format.json { head :no_content }
    end
  end

  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
    authorize @subscription
  end

  def check_policy
    authorize Subscription
  end

  def subscription_params
    params.require(:subscription).permit(
      :title, :note, :order_list_id, :user_id
    )
  end
end

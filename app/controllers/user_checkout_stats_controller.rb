class UserCheckoutStatsController < ApplicationController
  before_action :set_user_checkout_stat, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  after_action :convert_charset, only: :show

  # GET /user_checkout_stats
  # GET /user_checkout_stats.json
  def index
    @user_checkout_stats = UserCheckoutStat.order('id DESC').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_checkout_stats }
    end
  end

  # GET /user_checkout_stats/1
  # GET /user_checkout_stats/1.json
  def show
    if request.format.text?
      per_page = 65534
    else
      per_page = CheckoutStatHasUser.default_per_page
    end
    @stats = @user_checkout_stat.checkout_stat_has_users.order('checkouts_count DESC, user_id').page(params[:page]).per(per_page)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_checkout_stat }
      format.text
    end
  end

  # GET /user_checkout_stats/new
  # GET /user_checkout_stats/new.json
  def new
    @user_checkout_stat = UserCheckoutStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_checkout_stat }
    end
  end

  # GET /user_checkout_stats/1/edit
  def edit
  end

  # POST /user_checkout_stats
  # POST /user_checkout_stats.json
  def create
    @user_checkout_stat = UserCheckoutStat.new(user_checkout_stat_params)
    @user_checkout_stat.user = current_user

    respond_to do |format|
      if @user_checkout_stat.save
        UserCheckoutStatJob.perform_later(@user_checkout_stat)
        format.html { redirect_to @user_checkout_stat, notice: t('statistic.successfully_created', model: t('activerecord.models.user_checkout_stat')) }
        format.json { render json: @user_checkout_stat, status: :created, location: @user_checkout_stat }
      else
        format.html { render action: "new" }
        format.json { render json: @user_checkout_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_checkout_stats/1
  # PUT /user_checkout_stats/1.json
  def update
    respond_to do |format|
      if @user_checkout_stat.update(user_checkout_stat_params)
        if @user_checkout_stat.mode == 'import'
          UserCheckoutStatJob.perform_later(@user_checkout_stat)
        end
        format.html { redirect_to @user_checkout_stat, notice: t('controller.successfully_updated', model: t('activerecord.models.user_checkout_stat')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_checkout_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_checkout_stats/1
  # DELETE /user_checkout_stats/1.json
  def destroy
    @user_checkout_stat.destroy

    respond_to do |format|
      format.html { redirect_to user_checkout_stats_url }
      format.json { head :no_content }
    end
  end

  private

  def set_user_checkout_stat
    @user_checkout_stat = UserCheckoutStat.find(params[:id])
    authorize @user_checkout_stat
  end

  def check_policy
    authorize UserCheckoutStat
  end

  def user_checkout_stat_params
    params.require(:user_checkout_stat).permit(
      :start_date, :end_date, :note, :mode
    )
  end
end

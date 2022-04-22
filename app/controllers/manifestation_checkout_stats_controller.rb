class ManifestationCheckoutStatsController < ApplicationController
  before_action :set_manifestation_checkout_stat, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  after_action :convert_charset, only: :show

  # GET /manifestation_checkout_stats
  # GET /manifestation_checkout_stats.json
  def index
    @manifestation_checkout_stats = ManifestationCheckoutStat.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /manifestation_checkout_stats/1
  # GET /manifestation_checkout_stats/1.json
  def show
    if request.format.text?
      per_page = 65534
    else
      per_page = CheckoutStatHasManifestation.default_per_page
    end

    @carrier_type_results = Checkout.where(
      Checkout.arel_table[:created_at].gteq @manifestation_checkout_stat.start_date
    ).where(
      Checkout.arel_table[:created_at].lt @manifestation_checkout_stat.end_date
    ).joins(item: :manifestation).group(
      'checkouts.shelf_id', :carrier_type_id
    ).merge(
      Manifestation.where(carrier_type_id: CarrierType.pluck(:id))
    ).count(:id)

    @checkout_type_results = Checkout.where(
      Checkout.arel_table[:created_at].gteq @manifestation_checkout_stat.start_date
    ).where(
      Checkout.arel_table[:created_at].lt @manifestation_checkout_stat.end_date
    ).joins(item: :manifestation).group(
      'checkouts.shelf_id', :checkout_type_id
    ).count(:id)

    @stats = Checkout.where(
      Checkout.arel_table[:created_at].gteq @manifestation_checkout_stat.start_date
    ).where(
      Checkout.arel_table[:created_at].lt @manifestation_checkout_stat.end_date
    ).joins(item: :manifestation).group(:manifestation_id).merge(
      Manifestation.where(carrier_type_id: CarrierType.pluck(:id))
    ).order('count_id DESC').page(params[:page]).per(per_page)

    respond_to do |format|
      format.html # show.html.erb
      format.text
      format.js
    end
  end

  # GET /manifestation_checkout_stats/new
  def new
    @manifestation_checkout_stat = ManifestationCheckoutStat.new
    @manifestation_checkout_stat.start_date = Time.zone.now.beginning_of_day
    @manifestation_checkout_stat.end_date = Time.zone.now.beginning_of_day
  end

  # GET /manifestation_checkout_stats/1/edit
  def edit
  end

  # POST /manifestation_checkout_stats
  # POST /manifestation_checkout_stats.json
  def create
    @manifestation_checkout_stat = ManifestationCheckoutStat.new(manifestation_checkout_stat_params)
    @manifestation_checkout_stat.user = current_user

    respond_to do |format|
      if @manifestation_checkout_stat.save
        ManifestationCheckoutStatJob.perform_later(@manifestation_checkout_stat)
        format.html { redirect_to @manifestation_checkout_stat, notice: t('controller.successfully_created', model: t('activerecord.models.manifestation_checkout_stat')) }
        format.json { render json: @manifestation_checkout_stat, status: :created, location: @manifestation_checkout_stat }
      else
        format.html { render action: "new" }
        format.json { render json: @manifestation_checkout_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_checkout_stats/1
  # PUT /manifestation_checkout_stats/1.json
  def update
    respond_to do |format|
      if @manifestation_checkout_stat.update(manifestation_checkout_stat_params)
        if @manifestation_checkout_stat.mode == 'import'
          ManifestationCheckoutStatJob.perform_later(@manifestation_checkout_stat)
        end
        format.html { redirect_to @manifestation_checkout_stat, notice: t('controller.successfully_updated', model: t('activerecord.models.manifestation_checkout_stat')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @manifestation_checkout_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_checkout_stats/1
  # DELETE /manifestation_checkout_stats/1.json
  def destroy
    @manifestation_checkout_stat.destroy

    respond_to do |format|
      format.html { redirect_to manifestation_checkout_stats_url }
      format.json { head :no_content }
    end
  end

  private

  def set_manifestation_checkout_stat
    @manifestation_checkout_stat = ManifestationCheckoutStat.find(params[:id])
    authorize @manifestation_checkout_stat
  end

  def check_policy
    authorize ManifestationCheckoutStat
  end

  def manifestation_checkout_stat_params
    params.require(:manifestation_checkout_stat).permit(
      :start_date, :end_date, :note, :mode
    )
  end
end

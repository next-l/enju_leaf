class ManifestationCheckoutStatsController < ApplicationController
  load_and_authorize_resource
  after_filter :convert_charset, :only => :show

  # GET /manifestation_checkout_stats
  # GET /manifestation_checkout_stats.json
  def index
    @manifestation_checkout_stats = ManifestationCheckoutStat.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @manifestation_checkout_stats }
    end
  end

  # GET /manifestation_checkout_stats/1
  # GET /manifestation_checkout_stats/1.json
  def show
    CheckoutStatHasManifestation.per_page = 65534 if params[:format] == 'csv' or params[:format] == 'tsv'
    @stats = @manifestation_checkout_stat.checkout_stat_has_manifestations.order('checkouts_count DESC, manifestation_id').page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @manifestation_checkout_stat }
      format.csv
      format.tsv { send_data ManifestationCheckoutStat.get_manifestation_checkout_stats_tsv(@manifestation_checkout_stat, @stats) , :filename => Setting.manifestation_checkout_stats_print_tsv.filename }

    end
  end

  # GET /manifestation_checkout_stats/new
  # GET /manifestation_checkout_stats/new.json
  def new
    @manifestation_checkout_stat = ManifestationCheckoutStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @manifestation_checkout_stat }
    end
  end

  # GET /manifestation_checkout_stats/1/edit
  def edit
  end

  # POST /manifestation_checkout_stats
  # POST /manifestation_checkout_stats.json
  def create
    @manifestation_checkout_stat = ManifestationCheckoutStat.new(params[:manifestation_checkout_stat])

    respond_to do |format|
      if @manifestation_checkout_stat.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation_checkout_stat'))
        format.html { redirect_to(@manifestation_checkout_stat) }
        format.json { render :json => @manifestation_checkout_stat, :status => :created, :location => @manifestation_checkout_stat }
      else
        format.html { render :action => "new" }
        format.json { render :json => @manifestation_checkout_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_checkout_stats/1
  # PUT /manifestation_checkout_stats/1.json
  def update
    respond_to do |format|
      if @manifestation_checkout_stat.update_attributes(params[:manifestation_checkout_stat])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.manifestation_checkout_stat'))
        format.html { redirect_to(@manifestation_checkout_stat) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @manifestation_checkout_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_checkout_stats/1
  # DELETE /manifestation_checkout_stats/1.json
  def destroy
    @manifestation_checkout_stat.destroy

    respond_to do |format|
      format.html { redirect_to(manifestation_checkout_stats_url) }
      format.json { head :no_content }
    end
  end
end

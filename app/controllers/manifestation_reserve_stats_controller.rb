class ManifestationReserveStatsController < ApplicationController
  load_and_authorize_resource
  after_filter :convert_charset, :only => :show

  # GET /manifestation_reserve_stats
  # GET /manifestation_reserve_stats.json
  def index
    @manifestation_reserve_stats = ManifestationReserveStat.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @manifestation_reserve_stats }
    end
  end

  # GET /manifestation_reserve_stats/1
  # GET /manifestation_reserve_stats/1.json
  def show
    ReserveStatHasManifestation.per_page = 65534 if params[:format] == 'csv' or params[:format] == 'tsv'
    @stats = @manifestation_reserve_stat.reserve_stat_has_manifestations.order('reserves_count DESC, manifestation_id').page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @manifestation_reserve_stat }
      format.csv
      format.tsv  { send_data ManifestationReserveStat.get_manifestation_reserve_stats_tsv(@manifestation_reserve_stat, @stats), :filename => Setting.manifestation_reserve_stats_print_tsv.filename }
    end
  end

  # GET /manifestation_reserve_stats/new
  # GET /manifestation_reserve_stats/new.json
  def new
    @manifestation_reserve_stat = ManifestationReserveStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @manifestation_reserve_stat }
    end
  end

  # GET /manifestation_reserve_stats/1/edit
  def edit
  end

  # POST /manifestation_reserve_stats
  # POST /manifestation_reserve_stats.json
  def create
    @manifestation_reserve_stat = ManifestationReserveStat.new(params[:manifestation_reserve_stat])

    respond_to do |format|
      if @manifestation_reserve_stat.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation_reserve_stat'))
        format.html { redirect_to(@manifestation_reserve_stat) }
        format.json { render :json => @manifestation_reserve_stat, :status => :created, :location => @manifestation_reserve_stat }
      else
        format.html { render :action => "new" }
        format.json { render :json => @manifestation_reserve_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestation_reserve_stats/1
  # PUT /manifestation_reserve_stats/1.json
  def update
    respond_to do |format|
      if @manifestation_reserve_stat.update_attributes(params[:manifestation_reserve_stat])
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.manifestation_reserve_stat'))
        format.html { redirect_to(@manifestation_reserve_stat) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @manifestation_reserve_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestation_reserve_stats/1
  # DELETE /manifestation_reserve_stats/1.json
  def destroy
    @manifestation_reserve_stat.destroy

    respond_to do |format|
      format.html { redirect_to(manifestation_reserve_stats_url) }
      format.json { head :no_content }
    end
  end
end

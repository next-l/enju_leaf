class ReserveStatHasManifestationsController < ApplicationController
  load_and_authorize_resource

  # GET /reserve_stat_has_manifestations
  # GET /reserve_stat_has_manifestations.json
  def index
    @reserve_stat_has_manifestations = ReserveStatHasManifestation.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @reserve_stat_has_manifestations }
    end
  end

  # GET /reserve_stat_has_manifestations/1
  # GET /reserve_stat_has_manifestations/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @reserve_stat_has_manifestation }
    end
  end

  # GET /reserve_stat_has_manifestations/new
  # GET /reserve_stat_has_manifestations/new.json
  def new
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @reserve_stat_has_manifestation }
    end
  end

  # GET /reserve_stat_has_manifestations/1/edit
  def edit
  end

  # POST /reserve_stat_has_manifestations
  # POST /reserve_stat_has_manifestations.json
  def create
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.new(params[:reserve_stat_has_manifestation])

    respond_to do |format|
      if @reserve_stat_has_manifestation.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.reserve_stat_has_manifestation'))
        format.html { redirect_to(@reserve_stat_has_manifestation) }
        format.json { render :json => @reserve_stat_has_manifestation, :status => :created, :location => @reserve_stat_has_manifestation }
      else
        format.html { render :action => "new" }
        format.json { render :json => @reserve_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reserve_stat_has_manifestations/1
  # PUT /reserve_stat_has_manifestations/1.json
  def update
    respond_to do |format|
      if @reserve_stat_has_manifestation.update_attributes(params[:reserve_stat_has_manifestation])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.reserve_stat_has_manifestation'))
        format.html { redirect_to(@reserve_stat_has_manifestation) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @reserve_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reserve_stat_has_manifestations/1
  # DELETE /reserve_stat_has_manifestations/1.json
  def destroy
    @reserve_stat_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(reserve_stat_has_manifestations_url) }
      format.json { head :no_content }
    end
  end
end

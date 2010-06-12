class ReserveStatHasManifestationsController < ApplicationController
  load_and_authorize_resource

  # GET /reserve_stat_has_manifestations
  # GET /reserve_stat_has_manifestations.xml
  def index
    @reserve_stat_has_manifestations = ReserveStatHasManifestation.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reserve_stat_has_manifestations }
    end
  end

  # GET /reserve_stat_has_manifestations/1
  # GET /reserve_stat_has_manifestations/1.xml
  def show
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reserve_stat_has_manifestation }
    end
  end

  # GET /reserve_stat_has_manifestations/new
  # GET /reserve_stat_has_manifestations/new.xml
  def new
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reserve_stat_has_manifestation }
    end
  end

  # GET /reserve_stat_has_manifestations/1/edit
  def edit
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.find(params[:id])
  end

  # POST /reserve_stat_has_manifestations
  # POST /reserve_stat_has_manifestations.xml
  def create
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.new(params[:reserve_stat_has_manifestation])

    respond_to do |format|
      if @reserve_stat_has_manifestation.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.reserve_stat_has_manifestation'))
        format.html { redirect_to(@reserve_stat_has_manifestation) }
        format.xml  { render :xml => @reserve_stat_has_manifestation, :status => :created, :location => @reserve_stat_has_manifestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reserve_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reserve_stat_has_manifestations/1
  # PUT /reserve_stat_has_manifestations/1.xml
  def update
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.find(params[:id])

    respond_to do |format|
      if @reserve_stat_has_manifestation.update_attributes(params[:reserve_stat_has_manifestation])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.reserve_stat_has_manifestation'))
        format.html { redirect_to(@reserve_stat_has_manifestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reserve_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reserve_stat_has_manifestations/1
  # DELETE /reserve_stat_has_manifestations/1.xml
  def destroy
    @reserve_stat_has_manifestation = ReserveStatHasManifestation.find(params[:id])
    @reserve_stat_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(reserve_stat_has_manifestations_url) }
      format.xml  { head :ok }
    end
  end
end

class BookmarkStatHasManifestationsController < ApplicationController
  load_and_authorize_resource

  # GET /bookmark_stat_has_manifestations
  # GET /bookmark_stat_has_manifestations.json
  def index
    @bookmark_stat_has_manifestations = BookmarkStatHasManifestation.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @bookmark_stat_has_manifestations }
    end
  end

  # GET /bookmark_stat_has_manifestations/1
  # GET /bookmark_stat_has_manifestations/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @bookmark_stat_has_manifestation }
    end
  end

  # GET /bookmark_stat_has_manifestations/new
  # GET /bookmark_stat_has_manifestations/new.json
  def new
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @bookmark_stat_has_manifestation }
    end
  end

  # GET /bookmark_stat_has_manifestations/1/edit
  def edit
  end

  # POST /bookmark_stat_has_manifestations
  # POST /bookmark_stat_has_manifestations.json
  def create
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.new(params[:bookmark_stat_has_manifestation])

    respond_to do |format|
      if @bookmark_stat_has_manifestation.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.bookmark_stat_has_manifestation'))
        format.html { redirect_to(@bookmark_stat_has_manifestation) }
        format.json { render :json => @bookmark_stat_has_manifestation, :status => :created, :location => @bookmark_stat_has_manifestation }
      else
        format.html { render :action => "new" }
        format.json { render :json => @bookmark_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bookmark_stat_has_manifestations/1
  # PUT /bookmark_stat_has_manifestations/1.json
  def update
    respond_to do |format|
      if @bookmark_stat_has_manifestation.update_attributes(params[:bookmark_stat_has_manifestation])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.bookmark_stat_has_manifestation'))
        format.html { redirect_to(@bookmark_stat_has_manifestation) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @bookmark_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmark_stat_has_manifestations/1
  # DELETE /bookmark_stat_has_manifestations/1.json
  def destroy
    @bookmark_stat_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(bookmark_stat_has_manifestations_url) }
      format.json { head :no_content }
    end
  end
end

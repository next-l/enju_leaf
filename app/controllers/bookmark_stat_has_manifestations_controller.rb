class BookmarkStatHasManifestationsController < ApplicationController
  load_and_authorize_resource

  # GET /bookmark_stat_has_manifestations
  # GET /bookmark_stat_has_manifestations.xml
  def index
    @bookmark_stat_has_manifestations = BookmarkStatHasManifestation.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookmark_stat_has_manifestations }
    end
  end

  # GET /bookmark_stat_has_manifestations/1
  # GET /bookmark_stat_has_manifestations/1.xml
  def show
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bookmark_stat_has_manifestation }
    end
  end

  # GET /bookmark_stat_has_manifestations/new
  # GET /bookmark_stat_has_manifestations/new.xml
  def new
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bookmark_stat_has_manifestation }
    end
  end

  # GET /bookmark_stat_has_manifestations/1/edit
  def edit
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.find(params[:id])
  end

  # POST /bookmark_stat_has_manifestations
  # POST /bookmark_stat_has_manifestations.xml
  def create
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.new(params[:bookmark_stat_has_manifestation])

    respond_to do |format|
      if @bookmark_stat_has_manifestation.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.bookmark_stat_has_manifestation'))
        format.html { redirect_to(@bookmark_stat_has_manifestation) }
        format.xml  { render :xml => @bookmark_stat_has_manifestation, :status => :created, :location => @bookmark_stat_has_manifestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bookmark_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bookmark_stat_has_manifestations/1
  # PUT /bookmark_stat_has_manifestations/1.xml
  def update
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.find(params[:id])

    respond_to do |format|
      if @bookmark_stat_has_manifestation.update_attributes(params[:bookmark_stat_has_manifestation])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.bookmark_stat_has_manifestation'))
        format.html { redirect_to(@bookmark_stat_has_manifestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookmark_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmark_stat_has_manifestations/1
  # DELETE /bookmark_stat_has_manifestations/1.xml
  def destroy
    @bookmark_stat_has_manifestation = BookmarkStatHasManifestation.find(params[:id])
    @bookmark_stat_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(bookmark_stat_has_manifestations_url) }
      format.xml  { head :ok }
    end
  end
end

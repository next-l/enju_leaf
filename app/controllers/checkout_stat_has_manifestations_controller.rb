class CheckoutStatHasManifestationsController < ApplicationController
  load_and_authorize_resource

  # GET /checkout_stat_has_manifestations
  # GET /checkout_stat_has_manifestations.xml
  def index
    @checkout_stat_has_manifestations = CheckoutStatHasManifestation.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checkout_stat_has_manifestations }
    end
  end

  # GET /checkout_stat_has_manifestations/1
  # GET /checkout_stat_has_manifestations/1.xml
  def show
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @checkout_stat_has_manifestation }
    end
  end

  # GET /checkout_stat_has_manifestations/new
  # GET /checkout_stat_has_manifestations/new.xml
  def new
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checkout_stat_has_manifestation }
    end
  end

  # GET /checkout_stat_has_manifestations/1/edit
  def edit
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.find(params[:id])
  end

  # POST /checkout_stat_has_manifestations
  # POST /checkout_stat_has_manifestations.xml
  def create
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.new(params[:checkout_stat_has_manifestation])

    respond_to do |format|
      if @checkout_stat_has_manifestation.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.checkout_stat_has_manifestation'))
        format.html { redirect_to(@checkout_stat_has_manifestation) }
        format.xml  { render :xml => @checkout_stat_has_manifestation, :status => :created, :location => @checkout_stat_has_manifestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @checkout_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_stat_has_manifestations/1
  # PUT /checkout_stat_has_manifestations/1.xml
  def update
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.find(params[:id])

    respond_to do |format|
      if @checkout_stat_has_manifestation.update_attributes(params[:checkout_stat_has_manifestation])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkout_stat_has_manifestation'))
        format.html { redirect_to(@checkout_stat_has_manifestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkout_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_stat_has_manifestations/1
  # DELETE /checkout_stat_has_manifestations/1.xml
  def destroy
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.find(params[:id])
    @checkout_stat_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(checkout_stat_has_manifestations_url) }
      format.xml  { head :ok }
    end
  end
end

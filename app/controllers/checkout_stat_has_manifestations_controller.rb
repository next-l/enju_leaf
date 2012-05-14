class CheckoutStatHasManifestationsController < ApplicationController
  load_and_authorize_resource

  # GET /checkout_stat_has_manifestations
  # GET /checkout_stat_has_manifestations.json
  def index
    @checkout_stat_has_manifestations = CheckoutStatHasManifestation.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @checkout_stat_has_manifestations }
    end
  end

  # GET /checkout_stat_has_manifestations/1
  # GET /checkout_stat_has_manifestations/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @checkout_stat_has_manifestation }
    end
  end

  # GET /checkout_stat_has_manifestations/new
  # GET /checkout_stat_has_manifestations/new.json
  def new
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @checkout_stat_has_manifestation }
    end
  end

  # GET /checkout_stat_has_manifestations/1/edit
  def edit
  end

  # POST /checkout_stat_has_manifestations
  # POST /checkout_stat_has_manifestations.json
  def create
    @checkout_stat_has_manifestation = CheckoutStatHasManifestation.new(params[:checkout_stat_has_manifestation])

    respond_to do |format|
      if @checkout_stat_has_manifestation.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.checkout_stat_has_manifestation'))
        format.html { redirect_to(@checkout_stat_has_manifestation) }
        format.json { render :json => @checkout_stat_has_manifestation, :status => :created, :location => @checkout_stat_has_manifestation }
      else
        format.html { render :action => "new" }
        format.json { render :json => @checkout_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_stat_has_manifestations/1
  # PUT /checkout_stat_has_manifestations/1.json
  def update
    respond_to do |format|
      if @checkout_stat_has_manifestation.update_attributes(params[:checkout_stat_has_manifestation])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkout_stat_has_manifestation'))
        format.html { redirect_to(@checkout_stat_has_manifestation) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @checkout_stat_has_manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_stat_has_manifestations/1
  # DELETE /checkout_stat_has_manifestations/1.json
  def destroy
    @checkout_stat_has_manifestation.destroy

    respond_to do |format|
      format.html { redirect_to(checkout_stat_has_manifestations_url) }
      format.json { head :no_content }
    end
  end
end

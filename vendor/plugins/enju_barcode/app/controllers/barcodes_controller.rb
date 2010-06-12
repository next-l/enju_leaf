class BarcodesController < ApplicationController
  load_and_authorize_resource

  # GET /barcodes
  # GET /barcodes.xml
  def index
    @barcodes = Barcode.paginate(:all, :page => params[:page])

    if params[:mode] == 'barcode'
      render :action => 'barcode', :layout => false
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @barcodes }
    end
  end

  # GET /barcodes/1
  # GET /barcodes/1.xml
  def show
    @barcode = Barcode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @barcode }
      format.png
    end
  end

  # GET /barcodes/new
  # GET /barcodes/new.xml
  def new
    @barcode = Barcode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @barcode }
    end
  end

  # GET /barcodes/1/edit
  def edit
    @barcode = Barcode.find(params[:id])
  end

  # POST /barcodes
  # POST /barcodes.xml
  def create
    @barcode = Barcode.new(params[:barcode])

    respond_to do |format|
      if @barcode.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.barcode'))
        format.html { redirect_to(@barcode) }
        format.xml  { render :xml => @barcode, :status => :created, :location => @barcode }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @barcode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /barcodes/1
  # PUT /barcodes/1.xml
  def update
    @barcode = Barcode.find(params[:id])

    respond_to do |format|
      if @barcode.update_attributes(params[:barcode])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.barcode'))
        format.html { redirect_to(@barcode) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @barcode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /barcodes/1
  # DELETE /barcodes/1.xml
  def destroy
    @barcode = Barcode.find(params[:id])
    @barcode.destroy

    respond_to do |format|
      format.html { redirect_to(barcodes_url) }
      format.xml  { head :ok }
    end
  end
end

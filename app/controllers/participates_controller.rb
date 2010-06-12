class ParticipatesController < ApplicationController
  load_and_authorize_resource

  # GET /participates
  # GET /participates.xml
  def index
    @participates = Participate.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @participates }
    end
  end

  # GET /participates/1
  # GET /participates/1.xml
  def show
    @participate = Participate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participate }
    end
  end

  # GET /participates/new
  # GET /participates/new.xml
  def new
    @participate = Participate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participate }
    end
  end

  # GET /participates/1/edit
  def edit
    @participate = Participate.find(params[:id])
  end

  # POST /participates
  # POST /participates.xml
  def create
    @participate = Participate.new(params[:participate])

    respond_to do |format|
      if @participate.save
        flash[:notice] = 'Participate was successfully created.'
        format.html { redirect_to(@participate) }
        format.xml  { render :xml => @participate, :status => :created, :location => @participate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @participate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participates/1
  # PUT /participates/1.xml
  def update
    @participate = Participate.find(params[:id])

    respond_to do |format|
      if @participate.update_attributes(params[:participate])
        flash[:notice] = 'Participate was successfully updated.'
        format.html { redirect_to(@participate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @participate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participates/1
  # DELETE /participates/1.xml
  def destroy
    @participate = Participate.find(params[:id])
    @participate.destroy

    respond_to do |format|
      format.html { redirect_to(participates_url) }
      format.xml  { head :ok }
    end
  end
end

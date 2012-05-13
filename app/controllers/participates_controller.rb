class ParticipatesController < ApplicationController
  load_and_authorize_resource

  # GET /participates
  # GET /participates.json
  def index
    @participates = Participate.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @participates }
    end
  end

  # GET /participates/1
  # GET /participates/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @participate }
    end
  end

  # GET /participates/new
  # GET /participates/new.json
  def new
    @participate = Participate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @participate }
    end
  end

  # GET /participates/1/edit
  def edit
  end

  # POST /participates
  # POST /participates.json
  def create
    @participate = Participate.new(params[:participate])

    respond_to do |format|
      if @participate.save
        flash[:notice] = 'Participate was successfully created.'
        format.html { redirect_to(@participate) }
        format.json { render :json => @participate, :status => :created, :location => @participate }
      else
        format.html { render :action => "new" }
        format.json { render :json => @participate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participates/1
  # PUT /participates/1.json
  def update
    respond_to do |format|
      if @participate.update_attributes(params[:participate])
        flash[:notice] = 'Participate was successfully updated.'
        format.html { redirect_to(@participate) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @participate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participates/1
  # DELETE /participates/1.json
  def destroy
    @participate.destroy

    respond_to do |format|
      format.html { redirect_to(participates_url) }
      format.json { head :no_content }
    end
  end
end

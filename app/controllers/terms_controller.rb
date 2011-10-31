class TermsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    @terms = Term.all
  end

  def new
    @term = Term.new
  end

  def create
    @term = Term.new(params[:term])

    respond_to do |format|
      if @term.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.term'))
        format.html { redirect_to(@term) }
        format.xml  { render :xml => @term, :status => :created, :location => @term }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @term.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @term = Term.find(params[:id])
  end

  def update
    @term = Term.find(params[:id])

    respond_to do |format|
      if @term.update_attributes(params[:term])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.term'))
        format.html { redirect_to(@term) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @term.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @term = Term.find(params[:id])
  end

  def destroy
    @term = Term.find(params[:id])
    @term.destroy

    respond_to do |format|
      format.html { redirect_to(terms_url) }
      format.xml  { head :ok }
    end
  end
end

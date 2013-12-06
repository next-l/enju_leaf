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
        format.json { render :json => @term, :status => :created, :location => @term }
      else
        format.html { render :action => "new" }
        format.json { render :json => @term.errors, :status => :unprocessable_entity }
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
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @term.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @term = Term.find(params[:id])
  end

  def destroy
    @term = Term.find(params[:id])
    respond_to do |format|
      if @term.destroy?
        @term.destroy
        format.html { redirect_to(terms_url) }
        format.json { head :no_content }
      else
        flash[:message] = t('term.cannot_delete')
        @terms = Term.all
      end
    end
  end

  def get_term
    return nil unless request.xhr?
    unless params[:term_id].blank?
      term = Term.find(params[:term_id])
      render :json => { :success => 1, :start_at => l(term.start_at, :format => :only_date), :end_at => l(term.end_at, :format => :only_date) }
    end
  end
end

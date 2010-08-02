# -*- encoding: utf-8 -*-
class ClassificationsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_subject, :get_classification_type
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /classifications
  # GET /classifications.xml
  def index
    search = Sunspot.new_search(Classification)
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
      search.build do
        fulltext query
      end
    end
    unless params[:mode] == 'add'
      subject = @subject
      classification_type = @classification_type
      search.build do
        with(:subject_ids).equal_to subject.id if subject
        with(:classification_type_id).equal_to classification_type.id if classification_type
      end
    end

    page = params[:page] || 1
    begin
      search.query.paginate(page.to_i, Classification.per_page)
      @classifications = search.execute!.results
    rescue RSolr::RequestError
      @classifications = WillPaginate::Collection.create(1,1,0) do end
    end

    session[:params] = {} unless session[:params]
    session[:params][:classification] = params

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classifications }
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to classifications_url
    return
  end

  # GET /classifications/1
  # GET /classifications/1.xml
  def show
    @classification = Classification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classification }
    end
  end

  # GET /classifications/new
  # GET /classifications/new.xml
  def new
    @classification_types = ClassificationType.all
    @classification = Classification.new
    @classification.classification_type = @classification_type

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classification }
    end
  end

  # GET /classifications/1/edit
  def edit
    @classification = Classification.find(params[:id])
    @classification_types = ClassificationType.all
  end

  # POST /classifications
  # POST /classifications.xml
  def create
    @classification = Classification.new(params[:classification])

    respond_to do |format|
      if @classification.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.classification'))
        format.html { redirect_to(@classification) }
        format.xml  { render :xml => @classification, :status => :created, :location => @classification }
      else
        @classification_types = ClassificationType.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classifications/1
  # PUT /classifications/1.xml
  def update
    @classification = Classification.find(params[:id])

    respond_to do |format|
      if @classification.update_attributes(params[:classification])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.classification'))
        format.html { redirect_to(@classification) }
        format.xml  { head :ok }
      else
        @classification_types = ClassificationType.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classifications/1
  # DELETE /classifications/1.xml
  def destroy
    @classification = Classification.find(params[:id])
    @classification.destroy

    respond_to do |format|
      format.html { redirect_to(classifications_url) }
      format.xml  { head :ok }
    end
  end

  def get_classification_type
    @classification_type = ClassificationType.find(params[:classification_type_id]) rescue nil
  end
end

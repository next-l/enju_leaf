class WorkHasSubjectsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_work, :get_subject
  before_filter :get_patron
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /work_has_subjects
  # GET /work_has_subjects.xml
  def index
    if @work
      @work_has_subjects = @work.work_has_subjects.paginate(:all, :page => params[:page])
    elsif @subject
      @work_has_subjects = @subject.work_has_subjects.paginate(:all, :page => params[:page])
    else
      @work_has_subjects = WorkHasSubject.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @work_has_subjects }
    end
  end

  # GET /work_has_subjects/1
  # GET /work_has_subjects/1.xml
  def show
    @work_has_subject = WorkHasSubject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @work_has_subject }
    end
  end

  # GET /work_has_subjects/new
  # GET /work_has_subjects/new.xml
  def new
    @work_has_subject = WorkHasSubject.new
    @work_has_subject.work = @work
    @work_has_subject.subject = @subject

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work_has_subject }
    end
  end

  # GET /work_has_subjects/1/edit
  def edit
    @work_has_subject = WorkHasSubject.find(params[:id])
  end

  # POST /work_has_subjects
  # POST /work_has_subjects.xml
  def create
    @work_has_subject = WorkHasSubject.new(params[:work_has_subject])

    respond_to do |format|
      if @work_has_subject.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work_has_subject'))
        format.html { redirect_to(@work_has_subject) }
        format.xml  { render :xml => @work_has_subject, :status => :created, :location => @work_has_subject }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_has_subjects/1
  # PUT /work_has_subjects/1.xml
  def update
    @work_has_subject = WorkHasSubject.find(params[:id])

    respond_to do |format|
      if @work_has_subject.update_attributes(params[:work_has_subject])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work_has_subject'))
        format.html { redirect_to(@work_has_subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_has_subjects/1
  # DELETE /work_has_subjects/1.xml
  def destroy
    @work_has_subject = WorkHasSubject.find(params[:id])
    @work_has_subject.destroy

    respond_to do |format|
      case
      when @work
        format.html { redirect_to(work_work_has_subjects_url(@work)) }
        format.xml  { head :ok }
      when @subject
        format.html { redirect_to(subject_work_has_subjects_url(@subject)) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(work_has_subjects_url) }
        format.xml  { head :ok }
      end
    end
  end
end

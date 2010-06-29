class SubjectHeadingTypeHasSubjectsController < ApplicationController
  load_and_authorize_resource
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  # GET /subject_heading_type_has_subjects
  # GET /subject_heading_type_has_subjects.xml
  def index
    @subject_heading_type_has_subjects = SubjectHeadingTypeHasSubject.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subject_heading_type_has_subjects }
    end
  end

  # GET /subject_heading_type_has_subjects/1
  # GET /subject_heading_type_has_subjects/1.xml
  def show
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject_heading_type_has_subject }
    end
  end

  # GET /subject_heading_type_has_subjects/new
  # GET /subject_heading_type_has_subjects/new.xml
  def new
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject_heading_type_has_subject }
    end
  end

  # GET /subject_heading_type_has_subjects/1/edit
  def edit
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.find(params[:id])
  end

  # POST /subject_heading_type_has_subjects
  # POST /subject_heading_type_has_subjects.xml
  def create
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.new(params[:subject_heading_type_has_subject])

    respond_to do |format|
      if @subject_heading_type_has_subject.save
        flash[:notice] = 'SubjectHeadingTypeHasSubject was successfully created.'
        format.html { redirect_to(@subject_heading_type_has_subject) }
        format.xml  { render :xml => @subject_heading_type_has_subject, :status => :created, :location => @subject_heading_type_has_subject }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject_heading_type_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subject_heading_type_has_subjects/1
  # PUT /subject_heading_type_has_subjects/1.xml
  def update
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.find(params[:id])

    respond_to do |format|
      if @subject_heading_type_has_subject.update_attributes(params[:subject_heading_type_has_subject])
        flash[:notice] = 'SubjectHeadingTypeHasSubject was successfully updated.'
        format.html { redirect_to(@subject_heading_type_has_subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject_heading_type_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subject_heading_type_has_subjects/1
  # DELETE /subject_heading_type_has_subjects/1.xml
  def destroy
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.find(params[:id])
    @subject_heading_type_has_subject.destroy

    respond_to do |format|
      format.html { redirect_to(subject_heading_type_has_subjects_url) }
      format.xml  { head :ok }
    end
  end
end

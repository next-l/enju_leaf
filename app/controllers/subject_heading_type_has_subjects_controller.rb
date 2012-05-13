class SubjectHeadingTypeHasSubjectsController < ApplicationController
  load_and_authorize_resource
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /subject_heading_type_has_subjects
  # GET /subject_heading_type_has_subjects.json
  def index
    @subject_heading_type_has_subjects = SubjectHeadingTypeHasSubject.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @subject_heading_type_has_subjects }
    end
  end

  # GET /subject_heading_type_has_subjects/1
  # GET /subject_heading_type_has_subjects/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @subject_heading_type_has_subject }
    end
  end

  # GET /subject_heading_type_has_subjects/new
  # GET /subject_heading_type_has_subjects/new.json
  def new
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @subject_heading_type_has_subject }
    end
  end

  # GET /subject_heading_type_has_subjects/1/edit
  def edit
  end

  # POST /subject_heading_type_has_subjects
  # POST /subject_heading_type_has_subjects.json
  def create
    @subject_heading_type_has_subject = SubjectHeadingTypeHasSubject.new(params[:subject_heading_type_has_subject])

    respond_to do |format|
      if @subject_heading_type_has_subject.save
        flash[:notice] = 'SubjectHeadingTypeHasSubject was successfully created.'
        format.html { redirect_to(@subject_heading_type_has_subject) }
        format.json { render :json => @subject_heading_type_has_subject, :status => :created, :location => @subject_heading_type_has_subject }
      else
        format.html { render :action => "new" }
        format.json { render :json => @subject_heading_type_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subject_heading_type_has_subjects/1
  # PUT /subject_heading_type_has_subjects/1.json
  def update
    respond_to do |format|
      if @subject_heading_type_has_subject.update_attributes(params[:subject_heading_type_has_subject])
        flash[:notice] = 'SubjectHeadingTypeHasSubject was successfully updated.'
        format.html { redirect_to(@subject_heading_type_has_subject) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @subject_heading_type_has_subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subject_heading_type_has_subjects/1
  # DELETE /subject_heading_type_has_subjects/1.json
  def destroy
    @subject_heading_type_has_subject.destroy

    respond_to do |format|
      format.html { redirect_to(subject_heading_type_has_subjects_url) }
      format.json { head :no_content }
    end
  end
end

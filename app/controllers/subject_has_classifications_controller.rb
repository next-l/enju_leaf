class SubjectHasClassificationsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_subject
  before_filter :get_classification

  # GET /subject_has_classifications
  # GET /subject_has_classifications.xml
  def index
    case when @subject
      @subject_has_classifications = @subject.subject_has_classifications.paginate(:all, :page => params[:page])
    when @classification
      @subject_has_classifications = @classification.subject_has_classifications.paginate(:all, :page => params[:page])
    else
      @subject_has_classifications = SubjectHasClassification.paginate(:all, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subject_has_classifications }
    end
  end

  # GET /subject_has_classifications/1
  # GET /subject_has_classifications/1.xml
  def show
    @subject_has_classification = SubjectHasClassification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject_has_classification }
    end
  end

  # GET /subject_has_classifications/new
  # GET /subject_has_classifications/new.xml
  def new
    @subject_has_classification = SubjectHasClassification.new
    @subject_has_classification.subject = @subject
    @subject_has_classification.classification = @classification

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject_has_classification }
    end
  end

  # GET /subject_has_classifications/1/edit
  def edit
    @subject_has_classification = SubjectHasClassification.find(params[:id])
  end

  # POST /subject_has_classifications
  # POST /subject_has_classifications.xml
  def create
    @subject_has_classification = SubjectHasClassification.new(params[:subject_has_classification])

    respond_to do |format|
      if @subject_has_classification.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.subject_has_classification'))
        format.html { redirect_to(@subject_has_classification) }
        format.xml  { render :xml => @subject_has_classification, :status => :created, :location => @subject_has_classification }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject_has_classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subject_has_classifications/1
  # PUT /subject_has_classifications/1.xml
  def update
    @subject_has_classification = SubjectHasClassification.find(params[:id])

    respond_to do |format|
      if @subject_has_classification.update_attributes(params[:subject_has_classification])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.subject_has_classification'))
        format.html { redirect_to(@subject_has_classification) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject_has_classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subject_has_classifications/1
  # DELETE /subject_has_classifications/1.xml
  def destroy
    @subject_has_classification = SubjectHasClassification.find(params[:id])
    @subject_has_classification.destroy

    respond_to do |format|
      if @subject
        format.html { redirect_to(subject_subject_has_classifications_url(@subject)) }
      elsif @classification
        format.html { redirect_to(classification_subject_has_classifications_url(@classification)) }
      else
        format.html { redirect_to(subject_has_classifications_url) }
      end
      format.xml  { head :ok }
    end
  end
end

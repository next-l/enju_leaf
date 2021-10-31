class ClassificationsController < ApplicationController
  before_action :set_classification, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_subject, :get_classification_type

  # GET /classifications
  # GET /classifications.json
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
    search.query.paginate(page.to_i, Classification.default_per_page)
    @classifications = search.execute!.results

    session[:params] = {} unless session[:params]
    session[:params][:classification] = params

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @classifications }
    end
  end

  # GET /classifications/1
  # GET /classifications/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @classification }
    end
  end

  # GET /classifications/new
  # GET /classifications/new.json
  def new
    @classification_types = ClassificationType.all
    @classification = Classification.new
    @classification.classification_type = @classification_type

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @classification }
    end
  end

  # GET /classifications/1/edit
  def edit
    @classification_types = ClassificationType.all
  end

  # POST /classifications
  # POST /classifications.json
  def create
    @classification = Classification.new(classification_params)

    respond_to do |format|
      if @classification.save
        format.html { redirect_to @classification, notice: t('controller.successfully_created', model: t('activerecord.models.classification')) }
        format.json { render json: @classification, status: :created, location: @classification }
      else
        @classification_types = ClassificationType.all
        format.html { render action: "new" }
        format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /classifications/1
  # PUT /classifications/1.json
  def update
    respond_to do |format|
      if @classification.update(classification_params)
        format.html { redirect_to @classification, notice: t('controller.successfully_updated', model: t('activerecord.models.classification')) }
        format.json { head :no_content }
      else
        @classification_types = ClassificationType.all
        format.html { render action: "edit" }
        format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /classifications/1
  # DELETE /classifications/1.json
  def destroy
    @classification = Classification.find(params[:id])
    @classification.destroy

    respond_to do |format|
      format.html { redirect_to classifications_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.classification')) }
      format.json { head :no_content }
    end
  end

  private
  def set_classification
    @classification = Classification.find(params[:id])
    authorize @classification
  end

  def check_policy
    authorize Classification
  end

  def classification_params
    params.require(:classification).permit(
      :parent_id, :category, :note, :classification_type_id, :url, :label
    )
  end

  def get_classification_type
    @classification_type = ClassificationType.find(params[:classification_type_id]) rescue nil
  end
end

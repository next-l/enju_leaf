class ClassificationTypesController < ApplicationController
  before_action :set_classification_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /classification_types
  # GET /classification_types.json
  def index
    @classification_types = ClassificationType.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @classification_types }
    end
  end

  # GET /classification_types/1
  # GET /classification_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @classification_type }
    end
  end

  # GET /classification_types/new
  # GET /classification_types/new.json
  def new
    @classification_type = ClassificationType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @classification_type }
    end
  end

  # GET /classification_types/1/edit
  def edit
  end

  # POST /classification_types
  # POST /classification_types.json
  def create
    @classification_type = ClassificationType.new(classification_type_params)

    respond_to do |format|
      if @classification_type.save
        format.html { redirect_to @classification_type, notice:  t('controller.successfully_created', model:  t('activerecord.models.classification_type')) }
        format.json { render json: @classification_type, status: :created, location: @classification_type }
      else
        format.html { render action: "new" }
        format.json { render json: @classification_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /classification_types/1
  # PUT /classification_types/1.json
  def update
    if params[:move]
      move_position(@classification_type, params[:move])
      return
    end

    respond_to do |format|
      if @classification_type.update(classification_type_params)
        format.html { redirect_to @classification_type, notice:  t('controller.successfully_updated', model:  t('activerecord.models.classification_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @classification_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /classification_types/1
  # DELETE /classification_types/1.json
  def destroy
    @classification_type.destroy

    respond_to do |format|
      format.html { redirect_to classification_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.classification_type')) }
      format.json { head :no_content }
    end
  end

  private
  def set_classification_type
    @classification_type = ClassificationType.find(params[:id])
    authorize @classification_type
  end

  def check_policy
    authorize ClassificationType
  end

  def classification_type_params
    params.require(:classification_type).permit(:name, :display_name, :note)
  end
end

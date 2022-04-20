class ClassificationTypesController < ApplicationController
  before_action :set_classification_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /classification_types
  def index
    @classification_types = ClassificationType.order(:position)
  end

  # GET /classification_types/1
  def show
  end

  # GET /classification_types/new
  def new
    @classification_type = ClassificationType.new
  end

  # GET /classification_types/1/edit
  def edit
  end

  # POST /classification_types
  def create
    @classification_type = ClassificationType.new(classification_type_params)

    respond_to do |format|
      if @classification_type.save
        format.html { redirect_to @classification_type, notice:  t('controller.successfully_created', model: t('activerecord.models.classification_type')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /classification_types/1
  def update
    if params[:move]
      move_position(@classification_type, params[:move])
      return
    end

    respond_to do |format|
      if @classification_type.update(classification_type_params)
        format.html { redirect_to @classification_type, notice:  t('controller.successfully_updated', model: t('activerecord.models.classification_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /classification_types/1
  def destroy
    @classification_type.destroy

    redirect_to classification_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.classification_type'))
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

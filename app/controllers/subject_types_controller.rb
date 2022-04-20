class SubjectTypesController < ApplicationController
  before_action :set_subject_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /subject_types
  def index
    @subject_types = SubjectType.order(:position)
  end

  # GET /subject_types/1
  def show
  end

  # GET /subject_types/new
  def new
    @subject_type = SubjectType.new
  end

  # GET /subject_types/1/edit
  def edit
  end

  # POST /subject_types
  def create
    @subject_type = SubjectType.new(subject_type_params)

    respond_to do |format|
      if @subject_type.save
        format.html { redirect_to @subject_type, notice:  t('controller.successfully_created', model: t('activerecord.models.subject_type')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /subject_types/1
  def update
    if params[:move]
      move_position(@subject_type, params[:move])
      return
    end

    respond_to do |format|
      if @subject_type.update(subject_type_params)
        format.html { redirect_to @subject_type, notice:  t('controller.successfully_updated', model: t('activerecord.models.subject_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /subject_types/1
  def destroy
    @subject_type.destroy

    respond_to do |format|
      format.html { redirect_to subject_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.subject_type')) }
    end
  end

  private

  def set_subject_type
    @subject_type = SubjectType.find(params[:id])
    authorize @subject_type
  end

  def check_policy
    authorize SubjectType
  end

  def subject_type_params
    params.require(:subject_type).permit(:name, :display_name, :note)
  end
end

class SubjectHeadingTypesController < ApplicationController
  before_action :set_subject_heading_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /subject_heading_types
  # GET /subject_heading_types.json
  def index
    @subject_heading_types = SubjectHeadingType.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subject_heading_types }
    end
  end

  # GET /subject_heading_types/1
  # GET /subject_heading_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subject_heading_type }
    end
  end

  # GET /subject_heading_types/new
  # GET /subject_heading_types/new.json
  def new
    @subject_heading_type = SubjectHeadingType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subject_heading_type }
    end
  end

  # GET /subject_heading_types/1/edit
  def edit
  end

  # POST /subject_heading_types
  # POST /subject_heading_types.json
  def create
    @subject_heading_type = SubjectHeadingType.new(subject_heading_type_params)

    respond_to do |format|
      if @subject_heading_type.save
        format.html { redirect_to @subject_heading_type, notice:  t('controller.successfully_created', model:  t('activerecord.models.subject_heading_type')) }
        format.json { render json: @subject_heading_type, status: :created, location: @subject_heading_type }
      else
        format.html { render action: "new" }
        format.json { render json: @subject_heading_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subject_heading_types/1
  # PUT /subject_heading_types/1.json
  def update
    if params[:move]
      move_position(@subject_heading_type, params[:move])
      return
    end

    respond_to do |format|
      if @subject_heading_type.update(subject_heading_type_params)
        format.html { redirect_to @subject_heading_type, notice:  t('controller.successfully_updated', model:  t('activerecord.models.subject_heading_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subject_heading_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subject_heading_types/1
  # DELETE /subject_heading_types/1.json
  def destroy
    @subject_heading_type.destroy

    respond_to do |format|
      format.html { redirect_to subject_heading_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.subject_heading_type')) }
      format.json { head :no_content }
    end
  end

  private
  def set_subject_heading_type
    @subject_heading_type = SubjectHeadingType.find(params[:id])
    authorize @subject_heading_type
  end

  def check_policy
    authorize SubjectHeadingType
  end

  def subject_heading_type_params
    params.require(:subject_heading_type).permit(:name, :display_name, :note)
  end
end

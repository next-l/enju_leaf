class NiiTypesController < ApplicationController
  before_action :set_nii_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /nii_types
  # GET /nii_types.json
  def index
    @nii_types = NiiType.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nii_types }
    end
  end

  # GET /nii_types/1
  # GET /nii_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nii_type }
    end
  end

  # GET /nii_types/new
  # GET /nii_types/new.json
  def new
    @nii_type = NiiType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @nii_type }
    end
  end

  # GET /nii_types/1/edit
  def edit
  end

  # POST /nii_types
  # POST /nii_types.json
  def create
    @nii_type = NiiType.new(nii_type_params)

    respond_to do |format|
      if @nii_type.save
        format.html { redirect_to @nii_type, notice:  t('controller.successfully_created', model:  t('activerecord.models.nii_type')) }
        format.json { render json: @nii_type, status: :created, location: @nii_type }
      else
        format.html { render action: "new" }
        format.json { render json: @nii_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /nii_types/1
  # PUT /nii_types/1.json
  def update
    if params[:move]
      move_position(@nii_type, params[:move])
      return
    end

    respond_to do |format|
      if @nii_type.update(nii_type_params)
        format.html { redirect_to @nii_type, notice:  t('controller.successfully_updated', model:  t('activerecord.models.nii_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @nii_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nii_types/1
  # DELETE /nii_types/1.json
  def destroy
    @nii_type.destroy

    respond_to do |format|
      format.html { redirect_to nii_types_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.nii_type')) }
      format.json { head :no_content }
    end
  end

  private
  def set_nii_type
    @nii_type = NiiType.find(params[:id])
    authorize @nii_type
  end

  def check_policy
    authorize NiiType
  end

  def nii_type_params
    params.require(:nii_type).permit(:name, :display_name, :note)
  end
end

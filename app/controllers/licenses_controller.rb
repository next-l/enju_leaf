class LicensesController < ApplicationController
  before_action :set_license, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /licenses
  # GET /licenses.json
  def index
    @licenses = License.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @licenses }
    end
  end

  # GET /licenses/1
  # GET /licenses/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @license }
    end
  end

  # GET /licenses/new
  # GET /licenses/new.json
  def new
    @license = License.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @license }
    end
  end

  # GET /licenses/1/edit
  def edit
  end

  # POST /licenses
  # POST /licenses.json
  def create
    @license = License.new(license_params)

    respond_to do |format|
      if @license.save
        format.html { redirect_to @license, notice: t('controller.successfully_created', model: t('activerecord.models.license')) }
        format.json { render json: @license, status: :created, location: @license }
      else
        format.html { render action: "new" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /licenses/1
  # PUT /licenses/1.json
  def update
    if params[:move]
      move_position(@license, params[:move])
      return
    end

    respond_to do |format|
      if @license.update(license_params)
        format.html { redirect_to @license, notice: t('controller.successfully_updated', model: t('activerecord.models.license')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /licenses/1
  # DELETE /licenses/1.json
  def destroy
    @license.destroy

    respond_to do |format|
      format.html { redirect_to licenses_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.license')) }
      format.json { head :no_content }
    end
  end

  private
  def set_license
    @license = License.find(params[:id])
    authorize @license
  end

  def check_policy
    authorize License
  end

  def license_params
    params.require(:license).permit(:name, :display_name, :note)
  end
end

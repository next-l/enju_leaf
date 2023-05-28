class PeriodicalsController < ApplicationController
  before_action :set_periodical, only: %i[ show edit update destroy ]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /periodicals or /periodicals.json
  def index
    @periodicals = Periodical.page(params[:page])
  end

  # GET /periodicals/1 or /periodicals/1.json
  def show
  end

  # GET /periodicals/new
  def new
    @periodical = Periodical.new
  end

  # GET /periodicals/1/edit
  def edit
  end

  # POST /periodicals or /periodicals.json
  def create
    @periodical = Periodical.new(periodical_params)

    respond_to do |format|
      if @periodical.save
        format.html { redirect_to periodical_url(@periodical), notice: "Periodical was successfully created." }
        format.json { render :show, status: :created, location: @periodical }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @periodical.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /periodicals/1 or /periodicals/1.json
  def update
    respond_to do |format|
      if @periodical.update(periodical_params)
        format.html { redirect_to periodical_url(@periodical), notice: "Periodical was successfully updated." }
        format.json { render :show, status: :ok, location: @periodical }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @periodical.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /periodicals/1 or /periodicals/1.json
  def destroy
    @periodical.destroy

    respond_to do |format|
      format.html { redirect_to periodicals_url, notice: "Periodical was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_periodical
      @periodical = Periodical.find(params[:id])
      authorize @periodical
    end

    def check_policy
      authorize Periodical
    end

    # Only allow a list of trusted parameters through.
    def periodical_params
      params.require(:periodical).permit(:original_title, :manifestation_id, :frequency_id)
    end
end

class NamesController < ApplicationController
  before_action :set_name, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /names
  def index
    @names = Name.paginate(params[:page])
  end

  # GET /names/1
  def show
  end

  # GET /names/new
  def new
    @name = Name.new
  end

  # GET /names/1/edit
  def edit
  end

  # POST /names
  def create
    @name = Name.new(name_params)

    if @name.save
      redirect_to @name, notice: 'Name was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /names/1
  def update
    if @name.update(name_params)
      redirect_to @name, notice: 'Name was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /names/1
  def destroy
    @name.destroy
    redirect_to names_url, notice: 'Name was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_name
      @name = Name.find(params[:id])
      authorize @name
    end

    # Only allow a trusted parameter "white list" through.
    def name_params
      params.require(:name).permit(:first_name, :middle_name, :last_name, :language_id, :profile_id, :position)
    end
end

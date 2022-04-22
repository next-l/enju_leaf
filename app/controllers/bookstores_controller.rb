class BookstoresController < ApplicationController
  before_action :set_bookstore, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /bookstores
  # GET /bookstores.json
  def index
    @bookstores = Bookstore.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /bookstores/1
  # GET /bookstores/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /bookstores/new
  def new
    @bookstore = Bookstore.new
  end

  # GET /bookstores/1/edit
  def edit
  end

  # POST /bookstores
  # POST /bookstores.json
  def create
    @bookstore = Bookstore.new(bookstore_params)

    respond_to do |format|
      if @bookstore.save
        format.html { redirect_to @bookstore, notice: t('controller.successfully_created', model: t('activerecord.models.bookstore')) }
        format.json { render json: @bookstore, status: :created, location: @bookstore }
      else
        format.html { render action: "new" }
        format.json { render json: @bookstore.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bookstores/1
  # PUT /bookstores/1.json
  def update
    if params[:move]
      move_position(@bookstore, params[:move])
      return
    end

    respond_to do |format|
      if @bookstore.update(bookstore_params)
        format.html { redirect_to @bookstore, notice: t('controller.successfully_updated', model: t('activerecord.models.bookstore')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bookstore.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookstores/1
  # DELETE /bookstores/1.json
  def destroy
    @bookstore.destroy

    respond_to do |format|
      format.html { redirect_to bookstores_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.bookstore')) }
      format.json { head :no_content }
    end
  end

  private

  def set_bookstore
    @bookstore = Bookstore.find(params[:id])
    authorize @bookstore
  end

  def check_policy
    authorize Bookstore
  end

  def bookstore_params
    params.require(:bookstore).permit(
      :name, :zip_code, :address, :note, :telephone_number,
      :fax_number, :url
    )
  end
end

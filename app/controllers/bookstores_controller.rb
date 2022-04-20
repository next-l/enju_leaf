class BookstoresController < ApplicationController
  before_action :set_bookstore, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /bookstores
  def index
    @bookstores = Bookstore.page(params[:page])
  end

  # GET /bookstores/1
  def show
  end

  # GET /bookstores/new
  def new
    @bookstore = Bookstore.new
  end

  # GET /bookstores/1/edit
  def edit
  end

  # POST /bookstores
  def create
    @bookstore = Bookstore.new(bookstore_params)

    respond_to do |format|
      if @bookstore.save
        format.html { redirect_to @bookstore, notice: t('controller.successfully_created', model: t('activerecord.models.bookstore')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /bookstores/1
  def update
    if params[:move]
      move_position(@bookstore, params[:move])
      return
    end

    respond_to do |format|
      if @bookstore.update(bookstore_params)
        format.html { redirect_to @bookstore, notice: t('controller.successfully_updated', model: t('activerecord.models.bookstore')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /bookstores/1
  def destroy
    @bookstore.destroy

    respond_to do |format|
      format.html { redirect_to bookstores_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.bookstore')) }
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

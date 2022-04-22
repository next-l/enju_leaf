class UseRestrictionsController < ApplicationController
  before_action :set_use_restriction, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /use_restrictions
  # GET /use_restrictions.json
  def index
    @use_restrictions = UseRestriction.order(:position)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /use_restrictions/1
  # GET /use_restrictions/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /use_restrictions/new
  def new
    @use_restriction = UseRestriction.new
  end

  # GET /use_restrictions/1/edit
  def edit
  end

  # POST /use_restrictions
  # POST /use_restrictions.json
  def create
    @use_restriction = UseRestriction.new(use_restriction_params)

    respond_to do |format|
      if @use_restriction.save
        format.html { redirect_to @use_restriction, notice: t('controller.successfully_created', model: t('activerecord.models.use_restriction')) }
        format.json { render json: @use_restriction, status: :created, location: @use_restriction }
      else
        format.html { render action: "new" }
        format.json { render json: @use_restriction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /use_restrictions/1
  # PUT /use_restrictions/1.json
  def update
    if params[:move]
      move_position(@use_restriction, params[:move])
      return
    end

    respond_to do |format|
      if @use_restriction.update(use_restriction_params)
        format.html { redirect_to @use_restriction, notice: t('controller.successfully_updated', model: t('activerecord.models.use_restriction')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @use_restriction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /use_restrictions/1
  # DELETE /use_restrictions/1.json
  def destroy
    @use_restriction.destroy

    respond_to do |format|
      format.html { redirect_to use_restrictions_url }
      format.json { head :no_content }
    end
  end

  private

  def set_use_restriction
    @use_restriction = UseRestriction.find(params[:id])
    authorize @use_restriction
  end

  def check_policy
    authorize UseRestriction
  end

  def use_restriction_params
    params.require(:use_restriction).permit(:name, :display_name, :note)
  end
end

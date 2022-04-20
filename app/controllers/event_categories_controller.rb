class EventCategoriesController < ApplicationController
  before_action :set_event_category, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /event_categories
  def index
    @event_categories = EventCategory.order(:position)
  end

  # GET /event_categories/1
  def show
  end

  # GET /event_categories/new
  def new
    @event_category = EventCategory.new
  end

  # GET /event_categories/1/edit
  def edit
  end

  # POST /event_categories
  def create
    @event_category = EventCategory.new(event_category_params)

    respond_to do |format|
      if @event_category.save
        format.html { redirect_to @event_category, notice:  t('controller.successfully_created', model: t('activerecord.models.event_category')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /event_categories/1
  def update
    if params[:move]
      move_position(@event_category, params[:move])
      return
    end

    respond_to do |format|
      if @event_category.update(event_category_params)
        format.html { redirect_to @event_category, notice:  t('controller.successfully_updated', model: t('activerecord.models.event_category')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /event_categories/1
  def destroy
    @event_category.destroy
    redirect_to event_categories_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.event_category'))
  end

  private
  def set_event_category
    @event_category = EventCategory.find(params[:id])
    authorize @event_category
  end

  def check_policy
    authorize EventCategory
  end

  def event_category_params
    params.require(:event_category).permit(:name, :display_name, :note)
  end
end

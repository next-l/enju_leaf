# -*- encoding: utf-8 -*-
class UserGroupsController < ApplicationController
  before_action :set_user_group, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :prepare_options, only: [:new, :edit]

  # GET /user_groups
  # GET /user_groups.json
  def index
    @user_groups = UserGroup.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_groups }
    end
  end

  # GET /user_groups/1
  # GET /user_groups/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_group }
    end
  end

  # GET /user_groups/new
  def new
    @user_group = UserGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_group }
    end
  end

  # GET /user_groups/1/edit
  def edit
  end

  # POST /user_groups
  # POST /user_groups.json
  def create
    @user_group = UserGroup.new(user_group_params)

    respond_to do |format|
      if @user_group.save
        format.html { redirect_to @user_group, notice: t('controller.successfully_created', model: t('activerecord.models.user_group')) }
        format.json { render json: @user_group, status: :created, location: @user_group }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_groups/1
  # PUT /user_groups/1.json
  def update
    if params[:move]
      move_position(@user_group, params[:move])
      return
    end

    respond_to do |format|
      if @user_group.update_attributes(user_group_params)
        format.html { redirect_to @user_group, notice: t('controller.successfully_updated', model: t('activerecord.models.user_group')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.json
  def destroy
    @user_group.destroy

    respond_to do |format|
      format.html { redirect_to user_groups_url }
      format.json { head :no_content }
    end
  end

  private
  def set_user_group
    @user_group = UserGroup.find(params[:id])
    authorize @user_group
    access_denied unless LibraryGroup.site_config.network_access_allowed?(request.ip)
  end

  def check_policy
    authorize UserGroup
  end

  def user_group_params
    params.require(:user_group).permit(
      :name, :display_name, :note, :valid_period_for_new_user,
      :expired_at, :number_of_day_to_notify_overdue,
      :number_of_day_to_notify_overdue,
      :number_of_day_to_notify_due_date,
      :number_of_time_to_notify_overdue,
      # EnjuCirculation
      {:user_group_has_checkout_types_attributes => [
        :id, :checkout_type_id, :checkout_limit, :checkout_period, :checkout_renewal_limit,
        :reservation_limit, :reservation_expired_period, :set_due_date_before_closing_day,
      ]},
    )
  end

  def prepare_options
    if defined?(EnjuCirculation)
      @checkout_types = CheckoutType.select([:id, :display_name, :position])
    end
  end
end

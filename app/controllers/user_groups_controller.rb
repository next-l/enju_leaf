# -*- encoding: utf-8 -*-
class UserGroupsController < ApplicationController
  before_action :set_user_group, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped, :only => :index
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /user_groups
  def index
    @user_groups = UserGroup.all
  end

  # GET /user_groups/1
  def show
  end

  # GET /user_groups/new
  def new
    @user_group = UserGroup.new
    authorize @user_group
  end

  # GET /user_groups/1/edit
  def edit
  end

  # POST /user_groups
  def create
    @user_group = UserGroup.new(user_group_params)
    authorize @user_group

    if @user_group.save
      redirect_to @user_group, :notice => t('controller.successfully_created', :model => t('activerecord.models.user_group'))
    else
      prepare_options
      render :action => "new"
    end
  end

  # PUT /user_groups/1
  def update
    if params[:move]
      move_position(@user_group, params[:move])
      return
    end

    if @user_group.update_attributes(user_group_params)
      redirect_to @user_group, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user_group'))
    else
      prepare_options
      render :action => "edit"
    end
  end

  # DELETE /user_groups/1
  def destroy
    @user_group.destroy
    redirect_to user_groups_url, notice: 'User group was successfully destroyed.'
  end

  private
  def set_user_group
    @user_group = UserGroup.find(params[:id])
    authorize @user_group
  end

  def prepare_options
    if defined?(EnjuCirculation)
      @checkout_types = CheckoutType.select([:id, :display_name, :position])
    end
  end

  def user_group_params
    params.require(:user_group).permit(
      :name, :display_name, :note, :valid_period_for_new_user,
      :expired_at, :number_of_day_to_notify_overdue,
      :number_of_day_to_notify_overdue,
      :number_of_day_to_notify_due_date,
      :number_of_time_to_notify_overdue
    )
  end
end

class RolesController < ApplicationController
  before_action :set_role, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /roles
  def index
    @roles = Role.order(:position)
  end

  # GET /roles/1
  def show
  end

  # GET /roles/1/edit
  def edit
  end

  # PUT /roles/1
  def update
    if params[:move]
      move_position(@role, params[:move])
      return
    end

    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to @role, notice: t('controller.successfully_updated', model: t('activerecord.models.role')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  private
  def set_role
    @role = Role.find(params[:id])
    authorize @role
  end

  def check_policy
    authorize Role
  end

  def role_params
    params.require(:role).permit(:name, :display_name, :note)
  end
end

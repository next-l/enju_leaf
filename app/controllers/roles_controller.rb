# == Schema Information
#
# Table name: roles
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :string
#  note         :text
#  created_at   :datetime
#  updated_at   :datetime
#  score        :integer          default(0), not null
#  position     :integer
#

class RolesController < ApplicationController
  before_action :set_role, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /roles
  # GET /roles.json
  def index
    @roles = Role.order(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @role }
    end
  end

  # GET /roles/1/edit
  def edit
  end

  # PUT /roles/1
  # PUT /roles/1.json
  def update
    if params[:move]
      move_position(@role, params[:move])
      return
    end

    respond_to do |format|
      if @role.update_attributes(role_params)
        format.html { redirect_to @role, notice: t('controller.successfully_updated', model: t('activerecord.models.role')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def set_role
    @role = Role.find(params[:id])
    authorize @role
    access_denied unless LibraryGroup.site_config.network_access_allowed?(request.ip)
  end

  def check_policy
    authorize Role
  end

  def role_params
    params.require(:role).permit(:name, :display_name, :note)
  end
end

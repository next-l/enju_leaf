class InventoriesController < ApplicationController
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /inventories
  # GET /inventories.json
  def index
    @inventories = Inventory.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @inventories }
    end
  end

  # GET /inventories/1
  # GET /inventories/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @inventory }
    end
  end

  private
  def set_inventory
    @inventory = Inventory.find(params[:id])
    authorize @inventory
  end

  def check_policy
    authorize Inventory
  end

  def inventory_params
    params.require(:inventory).permit(
      :item_id, :inventory_id, :note
    )
  end
end

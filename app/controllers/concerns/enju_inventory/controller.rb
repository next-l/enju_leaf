module EnjuInventory
  module Controller
    extend ActiveSupport::Concern

    def get_inventory_file
      @inventory_file = InventoryFile.find(params[:inventory_file_id]) if params[:inventory_file_id]
    end
  end
end

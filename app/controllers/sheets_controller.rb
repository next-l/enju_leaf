class SheetsController < InheritedResources::Base
  def index
    page = params[:page] || 1
    @sheets = Sheet.order("created_at").page (page)
  end
end

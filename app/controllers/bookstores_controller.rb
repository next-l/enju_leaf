class BookstoresController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @bookstore = Bookstore.find(params[:id])
    if params[:move]
      move_position(@bookstore, params[:move])
      return
    end
    update!
  end

  def index
    @bookstores = Bookstore.page(params[:page])
  end
end

class BookstoresController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource :except => :search_bookstores

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

  def search_bookstores
    return nil unless request.xhr?
    exist = true
    unless params[:input].blank?
      bookstores = Bookstore.search do
        fulltext "name_text:*#{params[:input]}*"
      end.results rescue nil
      exist = false if bookstores.size == 0
    end
    bookstores = Bookstore.all if bookstores.nil? or bookstores.size == 0
    render :json => { :success => 1, :bookstores => bookstores, :exist => exist }
  end
end

class LocSearchController < ApplicationController
  before_action :check_policy, only: [:index, :create]

  def index
    if params[:page].to_i <= 0
      page = 1
    else
      page = params[:page].to_i
    end
    @query = params[ :query ].to_s.strip
    books = LocSearch.search( @query, { page: page } )
    @books = Kaminari.paginate_array(
      books[:items],
      total_count: books[ :total_entries ]
    ).page( page ).per( 10 )
    respond_to do |format|
      format.html
    end
  end

  def create
    begin
      @manifestation = LocSearch.import_from_sru_response(params[:book].try(:[], 'lccn'))
    rescue EnjuLoc::RecordNotFound
    end
    respond_to do |format|
      if @manifestation.try(:save)
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.manifestation'))
        format.html { redirect_to manifestation_url(@manifestation) }
      else
        if @manifestation and not @manifestation.valid?
          flash[:notice] = @manifestation.errors.messages
        else
          flash[:notice] = t('enju_loc.record_not_found')
        end
        format.html { redirect_to loc_search_index_url }
      end
    end
  end

  private
  def check_policy
    authorize LocSearch
  end
end

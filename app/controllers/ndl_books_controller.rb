class NdlBooksController < ApplicationController
  before_action :check_policy, only: %i[index create]

  def index
    page = if params[:page].to_i.zero?
             1
    else
             params[:page]
    end
    @query = params[:query].to_s.strip
    books = NdlBook.search(params[:query], page)
    @books = Kaminari.paginate_array(
      books[:items], total_count: books[:total_entries]
    ).page(page).per(10)
  end

  def create
    unless params[:book]
      redirect_to ndl_books_url, notice: t("enju_ndl.record_not_found")
      return
    end

    begin
      @manifestation = NdlBook.import_from_sru_response(params[:book].try(:[], "iss_itemno"))
    rescue EnjuNdl::RecordNotFound
    end

    if @manifestation.try(:save)
      redirect_to manifestation_url(@manifestation), notice: t("controller.successfully_created", model: t("activerecord.models.manifestation"))
    else
      redirect_to ndl_books_url, notice: t("enju_ndl.record_not_found")
    end
  end

  private

  def check_policy
    authorize NdlBook
  end
end

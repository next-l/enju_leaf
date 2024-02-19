class Calil::BarcodesController < ApplicationController
  def new
    @library = Library.friendly.find(params[:library_id])
    authorize @library

    @calil_barcode = Calil::Barcode.new(name: @library.name)
  end

  def create
  end
end

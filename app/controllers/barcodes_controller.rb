class BarcodesController < ApplicationController
  # GET /barcodes/new
  def new
    @barcode = Barcode.new
    authorize @barcode
  end
end

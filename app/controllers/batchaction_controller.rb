class BatchactionController < ApplicationController
  def recept
    @statuscode = 200
    @msg = ""
    render :template => 'batchaction/recept', :layout => false
  end

end

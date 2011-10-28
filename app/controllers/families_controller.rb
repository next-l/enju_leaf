class FamiliesController < ApplicationController
  def index
    @families = Family.all
  end

  def show
  end

end

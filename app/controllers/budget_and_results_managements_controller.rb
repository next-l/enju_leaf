class BudgetAndResultsManagementsController < ApplicationController
  def index
    @term = Term.current_term
    @terms = Term.find(:all, :order => "start_at")
  end
end

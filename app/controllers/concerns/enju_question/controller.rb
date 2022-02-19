module EnjuQuestion
  module Controller
    extend ActiveSupport::Concern

    def get_question
      @question = Question.find(params[:question_id]) if params[:question_id]
      authorize @question, :show? if @question
    end
  end
end

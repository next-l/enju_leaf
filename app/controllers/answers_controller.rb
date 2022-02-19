class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_user, except: [:edit]
  before_action :get_question
  include EnjuQuestion::Controller

  # GET /answers
  # GET /answers.json
  def index
    if !current_user.try(:has_role?, 'Librarian')
      if @question
        unless @question.try(:shared?)
          access_denied; return
        end
      end
      if @user != current_user
        access_denied; return
      end
    end

    @count = {}
    if user_signed_in?
      if current_user.has_role?('Librarian')
        if @question
          @answers = @question.answers.order('answers.id DESC').page(params[:page])
        elsif @user
          @answers = @user.answers.order('answers.id DESC').page(params[:page])
        else
          @answers = Answer.order('answers.id DESC').page(params[:page])
        end
      else
        if @question
          if @question.shared?
            @answers = @question.answers.order('answers.id DESC').page(params[:page])
          else
            access_denied; return
          end
        elsif @user
          if @user == current_user
            @answers = @user.answers.order('answers.id DESC').page(params[:page])
          else
            access_denied; return
          end
        else
          access_denied; return
        end
      end
    else
      if @question
        @answers = @question.answers.order('answers.id DESC').page(params[:page])
      else
        access_denied; return
      end
    end
    @count[:query_result] = @answers.size

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @answers.to_json }
      format.rss  { render layout: false }
      format.atom
    end
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @answer.to_json }
    end
  end

  # GET /answers/new
  def new
    if @question
      @answer = current_user.answers.new
      @answer.question = @question
    else
      flash[:notice] = t('answer.specify_question')
      redirect_to questions_url
    end
  end

  # GET /answers/1/edit
  def edit
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new(answer_params)
    @answer.user = current_user
    unless @answer.question
      redirect_to questions_url
      return
    end

    respond_to do |format|
      if @answer.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.answer'))
        format.html { redirect_to @answer }
        format.json { render json: @answer, status: :created, location: answer_url(@answer) }
      else
        format.html { render action: "new" }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /answers/1
  # PUT /answers/1.json
  def update
    respond_to do |format|
      if @answer.update(answer_update_params)
        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.answer'))
        format.html { redirect_to @answer }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to question_answers_url(@answer.question) }
      format.json { head :no_content }
    end
  end

  private
  def set_answer
    @answer = Answer.find(params[:id])
    authorize @answer
  end

  def check_policy
    authorize Answer
  end

  def answer_params
    params.require(:answer).permit(
      :question_id, :body, :item_identifier_list, :url_list
    )
  end

  def answer_update_params
    params.require(:answer).permit(
      :body, :item_identifier_list, :url_list
    )
  end
end

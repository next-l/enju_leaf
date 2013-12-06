# -*- encoding: utf-8 -*-
class AnswersController < ApplicationController
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.answer'))", 'question_answers_path(params[:question_id])', :only => [:index]
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.answer'))", 'question_answer_path(params[:id])', :only => [:show]
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.answer'))", 'new_question_answer_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.answer'))", 'edit_question_answer_path(params[:id])', :only => [:edit, :update]
  load_and_authorize_resource
  before_filter :store_location, :only => [:index, :show, :new, :edit]
  before_filter :get_user, :except => [:edit]
  before_filter :get_question
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /answers
  # GET /answers.json
  def index
    begin
      if !current_user.has_role?('Librarian')
        if @question
          raise unless @question.shared?
        else
          raise unless current_user == @user
        end
      end
    rescue
      access_denied; return
    end

    @count = {}
    if user_signed_in?
      if current_user.has_role?('Librarian')
        if @question
          @answers = @question.answers.order('answers.id').page(params[:page])
        elsif @user
          @answers = @user.answers.order('answers.id').page(params[:page])
        else
          @answers = Answer.order('answers.id').page(params[:page])
        end
      else
        if @question
          if @question.user == current_user
            @answers = @question.answers.order('answers.id').page(params[:page])
          else
            @answers = @question.answers.public_answers.order('answers.id').page(params[:page])
          end
        elsif @user
          if @user == current_user
            @answers = @user.answers.order('answers.id').page(params[:page])
          else
            @answers = @user.answers.public_answers.order('answers.id').page(params[:page])
          end
        else
          @answers = Answer.public_answers.order('answers.id').page(params[:page])
        end
      end
    else
      @answers = Answer.public_answers.order('answers.id').page(params[:page])
    end
    @count[:query_result] = @answers.size

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @answers }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
    if @question
      @answer = @question.answers.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @answer }
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
    if @question
      @answer = @question.answers.find(params[:id])
    end
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = current_user.answers.new(params[:answer])
    unless @answer.question
      redirect_to questions_url
      return
    end

    respond_to do |format|
      if @answer.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.answer'))
        format.html { redirect_to question_answer_url(@answer.question, @answer) }
        format.json { render :json => @answer, :status => :created, :location => user_question_answer_url(@answer.question.user, @answer.question, @answer) }
        format.mobile { redirect_to question_url(@answer.question) }
      else
        format.html { render :action => "new" }
        format.json { render :json => @answer.errors, :status => :unprocessable_entity }
        format.mobile { render :action => "new" }
      end
    end
  end

  # PUT /answers/1
  # PUT /answers/1.json
  def update
    if @question
      @answer = @question.answers.find(params[:id])
    end

    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.answer'))
        format.html { redirect_to question_answer_url(@answer.question, @answer) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @answer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    if @question
      @answer = @question.answers.find(params[:id])
    end
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to question_answers_url(@answer.question) }
      format.json { head :no_content }
    end
  end
end

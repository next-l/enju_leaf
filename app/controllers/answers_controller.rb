# -*- encoding: utf-8 -*-
class AnswersController < ApplicationController
  load_and_authorize_resource
  before_filter :store_location, :only => [:index, :show, :new, :edit]
  before_filter :get_user_if_nil, :except => [:edit]
  before_filter :get_question
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /answers
  # GET /answers.xml
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
      format.html # index.rhtml
      format.xml  { render :xml => @answers.to_xml }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /answers/1
  # GET /answers/1.xml
  def show
    if @question
      @answer = @question.answers.find(params[:id])
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @answer.to_xml }
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

  # GET /answers/1;edit
  def edit
    if @question
      @answer = @question.answers.find(params[:id])
    end
  end

  # POST /answers
  # POST /answers.xml
  def create
    @answer = current_user.answers.new(params[:answer])
    unless @answer.question
      redirect_to questions_url
      return
    end

    respond_to do |format|
      if @answer.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.answer'))
        format.html { redirect_to user_question_answer_url(@answer.question.user, @answer.question, @answer) }
        format.xml  { render :xml => @answer, :status => :created, :location => user_question_answer_url(@answer.question.user, @answer.question, @answer) }
        format.mobile { redirect_to question_url(@answer.question) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @answer.errors.to_xml }
        format.mobile { render :action => "new" }
      end
    end
  end

  # PUT /answers/1
  # PUT /answers/1.xml
  def update
    if @question
      @answer = @question.answers.find(params[:id])
    end

    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.answer'))
        format.html { redirect_to user_question_answer_url(@answer.question.user.username, @answer.question, @answer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @answer.errors.to_xml }
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.xml
  def destroy
    if @question
      @answer = @question.answers.find(params[:id])
    end
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to user_question_answers_url(@answer.question.user.username, @answer.question) }
      format.xml  { head :ok }
    end
  end
end

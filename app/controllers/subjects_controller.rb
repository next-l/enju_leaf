class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :prepare_options, only: [:new, :edit]

  # GET /subjects
  # GET /subjects.json
  def index
    sort = {sort_by: 'created_at', order: 'desc'}
    case params[:sort_by]
    when 'name'
      sort[:sort_by] = 'term'
    end
    sort[:order] = 'asc' if params[:order] == 'asc'

    search = Subject.search
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
      query = query.gsub('　', ' ')
      search.build do
        fulltext query
      end
    end

    search.build do
      order_by sort[:sort_by], sort[:order]
    end

    role = current_user.try(:role) || Role.default
    search.build do
      with(:required_role_id).less_than_or_equal_to role.id
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, Subject.default_per_page)
    @subjects = search.execute!.results
    session[:params] = {} unless session[:params]
    session[:params][:subject] = params

    flash[:page_info] = {page: page, query: query}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subjects }
      format.rss
      format.atom
    end
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    if params[:term]
      subject = Subject.find_by(term: params[:term])
      redirected_to subject
      return
    end

    search = Sunspot.new_search(Manifestation)
    subject = @subject
    search.build do
      with(:subject_ids).equal_to subject.id if subject
    end
    page = params[:work_page] || 1
    search.query.paginate(page.to_i, Manifestation.default_per_page)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subject }
    end
  end

  # GET /subjects/new
  def new
    @subject = Subject.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = Subject.new(subject_params)

    respond_to do |format|
      if @subject.save
        format.html { redirect_to @subject, notice: t('controller.successfully_created', model: t('activerecord.models.subject')) }
        format.json { render json: @subject, status: :created, location: @subject }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.json
  def update
    respond_to do |format|
      if @subject.update(subject_params)
        format.html { redirect_to @subject, notice: t('controller.successfully_updated', model: t('activerecord.models.subject')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to subjects_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.subject')) }
      format.json { head :no_content }
    end
  end

  private
  def set_subject
    @subject = Subject.find(params[:id])
    authorize @subject
  end

  def check_policy
    authorize Subject
  end

  def subject_params
    params.require(:subject).permit(
      :parent_id, :use_term_id, :term, :term_transcription,
      :subject_type_id, :note, :required_role_id, :subject_heading_type_id
    )
  end

  def prepare_options
    @subject_heading_types = SubjectHeadingType.select([:id, :display_name, :position])
    @subject_types = SubjectType.select([:id, :display_name, :position])
  end
end

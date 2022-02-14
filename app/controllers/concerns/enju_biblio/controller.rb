module EnjuBiblio
  module Controller
    extend ActiveSupport::Concern

    private

    def get_work
      @work = Manifestation.find(params[:work_id]) if params[:work_id]
      authorize @work, :show? if @work
    end

    def get_expression
      @expression = Manifestation.find(params[:expression_id]) if params[:expression_id]
      authorize @expression, :show? if @expression
    end

    def get_manifestation
      @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
      authorize @manifestation, :show? if @manifestation
    end

    def get_item
      @item = Item.find(params[:item_id]) if params[:item_id]
      authorize @item, :show? if @item
    end

    def get_carrier_type
      @carrier_type = CarrierType.find(params[:carrier_type_id]) if params[:carrier_type_id]
    end

    def get_agent
      @agent = Agent.find(params[:agent_id]) if params[:agent_id]
      authorize @agent if @agent
    end

    def get_series_statement
      @series_statement = SeriesStatement.find(params[:series_statement_id]) if params[:series_statement_id]
    end

    def get_basket
      @basket = Basket.find(params[:basket_id]) if params[:basket_id]
    end

    def get_agent_merge_list
      @agent_merge_list = AgentMergeList.find(params[:agent_merge_list_id]) if params[:agent_merge_list_id]
    end

    def get_series_statement_merge_list
      @series_statement_merge_list = SeriesStatementMergeList.find(params[:series_statement_merge_list_id]) if params[:series_statement_merge_list_id]
    end

    def make_internal_query(search)
      # 内部的なクエリ
      set_role_query(current_user, search)

      unless params[:mode] == "add"
        expression = @expression
        agent = @agent
        manifestation = @manifestation
        reservable = @reservable
        carrier_type = params[:carrier_type]
        library = params[:library]
        language = params[:language]
        if defined?(EnjuSubject)
          subject = params[:subject]
          subject_by_term = Subject.find_by(term: params[:subject])
          @subject_by_term = subject_by_term
        end

        search.build do
          with(:publisher_ids).equal_to agent.id if agent
          with(:original_manifestation_ids).equal_to manifestation.id if manifestation
          with(:reservable).equal_to reservable unless reservable.nil?
          if carrier_type.present?
            with(:carrier_type).equal_to carrier_type
          end
          if library.present?
            library_list = library.split.uniq
            library_list.each do |lib|
              with(:library).equal_to lib
            end
          end
          if language.present?
            language_list = language.split.uniq
            language_list.each do |language|
              with(:language).equal_to language
            end
          end
          if defined?(EnjuSubject)
            if subject.present?
              with(:subject).equal_to subject_by_term.term
            end
          end
        end
      end
      search
    end
  end
end

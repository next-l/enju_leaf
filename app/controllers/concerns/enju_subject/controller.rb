module EnjuSubject
  module Controller

    private

    def get_subject_heading_type
      if params[:subject_heading_type_id]
        @subject_heading_type = SubjectHeadingType.find(params[:subject_heading_type_id])
        authorize @subject_heading_type, :show?
      end
    end

    def get_subject
      if params[:subject_id]
        @subject = Subject.find(params[:subject_id])
        authorize @subject, :show?
      end
    end

    def get_classification
      if params[:classification_id]
        @classification = Classification.find(params[:classification_id])
        authorize @classification, :show?
      end
    end
  end
end

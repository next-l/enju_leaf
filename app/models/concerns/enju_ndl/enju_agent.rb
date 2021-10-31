# frozen_string_literal: true

module EnjuNdl
  module EnjuAgent
    extend ActiveSupport::Concern

    included do
      has_one :ndla_record
    end
  end
end


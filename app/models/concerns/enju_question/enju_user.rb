module EnjuQuestion
  module EnjuUser
    extend ActiveSupport::Concern

    included do
      has_many :questions, dependent: :destroy
      has_many :answers, dependent: :destroy
    end

    def reset_answer_feed_token
      self.answer_feed_token = Devise.friendly_token
    end

    def delete_answer_feed_token
      self.answer_feed_token = nil
    end
  end
end

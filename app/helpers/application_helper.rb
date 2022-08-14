module ApplicationHelper
  def error_messages(model)
    if model.errors.any?
      render('page/error_message', model: model)
    end
  end
end

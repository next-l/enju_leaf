atom_feed(:url => questions_url(:format => :atom)) do |feed|
  if @user
    feed.title t('question.user_question', :login_name => @user.username)
  else
    feed.title t('question.library_group_question', :library_group_name => @library_group.display_name.localize)
  end
  feed.updated(@questions.first ? @questions.first.created_at : Time.zone.now)

  for question in @questions
    feed.entry(question) do |entry|
      entry.title(truncate(question.body))
      entry.author(question.user.username)
      entry.content(question.body)
    end
  end
end

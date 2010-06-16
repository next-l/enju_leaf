atom_feed(:url => answers_url(:format => :atom)) do |feed|
  if @user
    feed.title t('answer.user_answer', :login_name => @user.username)
  else
    feed.title t('answer.library_group_answer', :library_group_name => @library_group.display_name.localize)
  end
  feed.updated(@answers.first ? @answers.first.created_at : Time.zone.now)

  @answers.each do |answer|
    feed.entry(answer) do |entry|
      entry.title(truncate(answer.body))
      entry.author(answer.user.username)
      entry.content(answer.body)
    end
  end
end

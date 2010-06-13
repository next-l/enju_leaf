atom_feed do |feed|
  feed.title "#{@user.username}'s Inbox"
  feed.updated(@messages.first ? @messages.first.created_at : Time.zone.now)
  
  for message in @messages
    feed.entry(message, :url => user_message_url(message.receiver.username, message)) do |entry|
     entry.title   message.subject
      entry.content message.body, :type => 'html'
      
      entry.author do |author|
        author.name message.sender.login
      end
    end
  end
end

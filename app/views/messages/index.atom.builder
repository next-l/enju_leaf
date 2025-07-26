atom_feed do |feed|
  feed.title "#{@user.username}'s Inbox"
  feed.updated(@messages.first ? @messages.first.created_at : Time.zone.now)

  @messages.each do |message|
    feed.entry(message, url: message_url(message)) do |entry|
      entry.title message.subject
      entry.content message.body, type: "html"

      entry.author do |author|
        author.name message.sender.login
      end
    end
  end
end

module AgentsHelper
  include PictureFilesHelper
  def agent_custom_book_jacket(agent)
    link = ''
    agent.picture_files.each_with_index do |picture_file, i|
      if i == 0
        link += link_to(show_image(picture_file, size: :thumb), rails_blob_url(picture_file.attachment), rel: "agent_#{agent.id}")
      else
        link += content_tag :span, style: "display: none" do
          link_to(show_image(picture_file, size: :thumb),rails_blob_url(picture_file.attachment), rel: "agent_#{agent.id}")
        end
      end
    end
    link.html_safe
  end
end

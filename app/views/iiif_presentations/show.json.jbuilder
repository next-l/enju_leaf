json.set!('@context', 'http://iiif.io/api/presentation/3/context.json')
json.set!('type', 'Manifest')
json.set!('id', iiif_presentation_url(@manifestation))
json.label @manifestation.original_title
json.summary @manifestation.description

json.items do
  json.array! @manifestation.picture_files.each_with_index do |picture_file|
    json.id picture_file_url(picture_file)
    json.type 'Canvas'
    json.label picture_file.attachment.filename
    json.width picture_file.attachment.metadata['width']
    json.height picture_file.attachment.metadata['height']
    json.format picture_file.attachment.content_type
    json.items do
      json.array! [0] do
        json.id picture_file_url(picture_file)
        json.type 'AnnotationPage'
        json.items do
          json.array! [0] do
            json.id picture_file_url(picture_file)
            json.type 'Annotation'
            json.body do
              json.set!('id', "#{ENV['CANTALOUPE_BASE_URL']}/iiif/3/#{picture_file.id}/full/max/0/default.jpg")
              json.type 'Image'
              json.width picture_file.attachment.metadata['width']
              json.height picture_file.attachment.metadata['height']
              json.format picture_file.attachment.content_type
            end
            json.target picture_file_url(picture_file)
          end
        end
      end
    end
  end
end

json.set!('@context', 'http://iiif.io/api/presentation/2/context.json')
json.set!('@type', 'sc:Manifest')
json.set!('@id', iiif_image_url(@manifestation.id))
json.label @manifestation.original_title
json.description @manifestation.description
json.sequences do
  json.array! [0] do |a|
    json.set!('@type', 'sc:Sequence')
    json.viewingHint 'individuals'
    json.canvases do
      json.array! @manifestation.picture_files do |picture_file|
        json.set!('@id', picture_file_url(picture_file))
        json.set!('@type', 'sc:Canvas')
        json.label @manifestation.original_title
        json.width picture_file.picture_width
        json.height picture_file.picture_height
        json.images do
          json.array! [0] do |c|
            json.set!('@type', 'oa:Annotation')
            json.on picture_file_url(picture_file)
            json.motivation 'sc:painting'
            json.resource do
              json.set!('@id', "#{ENV['CANTALOUPE_BASE_URI']}/iiif/3/#{picture_file.id}/full/max/0/default.jpg")
              json.set!('@type', 'dctypes:Image')
              json.width picture_file.picture_width
              json.height picture_file.picture_height
              json.format picture_file.picture_content_type
              json.service do
                json.set!('@context', 'http://iiif.io/api/image/3/context.json')
                json.set!('@id', "#{ENV['CANTALOUPE_BASE_URI']}/iiif/3/#{picture_file.id}")
                json.profile 'http://iiif.io/api/image/3/level1.json'
              end
            end
          end
        end
      end
    end
  end
end

json.set!('@context', 'http://iiif.io/api/presentation/2/context.json')
json.set!('@type', 'sc:Manifest')
json.set!('@id', iiif_image_url(@manifestation.id, format: :json))
json.label @manifestation.original_title
json.sequences do
  json.array! [0] do |a|
    json.set!('@type', 'sc:Sequence')
    json.viewingHint 'individuals'
    json.canvases do
      json.array! [0] do |c|
        json.set!('@id', picture_file_url(picture_file))
        json.set!('@type', 'sc:Canvas')
        json.label @manifestation.original_title
        json.width 1024
        json.height 1024
        json.images do
          json.array! @manifestation.picture_files do |picture_file|
            json.set!('@type', 'oa:Annotation')
            json.on picture_file_url(picture_file)
            json.motivation 'sc:painting'
            json.resource do
              json.set!('@id', "#{ENV['ENJU_LEAF_BASE_URL']}/iiif/3/#{picture_file.id}/full/max/0/default.jpg")
              json.set!('@type', 'dctypes:Image')
              json.service do
                json.set!('@context', 'http://iiif.io/api/image/3/context.json')
                json.set!('@id', "#{ENV['ENJU_LEAF_BASE_URL']}/iiif/3/#{picture_file.id}")
                json.profile 'http://iiif.io/api/image/3/level1.json'
              end
            end
          end
        end
      end
    end
  end
end

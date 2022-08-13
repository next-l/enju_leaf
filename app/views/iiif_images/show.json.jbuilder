json.set!('@context', 'http://iiif.io/api/presentation/2/context.json')
json.set!('@type', 'sc:Manifest')
json.set!('@id', iiif_image_url(@manifestation.id, format: :json))
json.label @manifestation.original_title
json.seeAlso manifestation_url(@manifestation, format: :download)
json.thumbnail "#{ENV['ENJU_LEAF_BASE_URL']}/image-service/#{@manifestation.id}")
json.sequences do
  json.array! [0] do |a|
    json.set!('@type', 'sc:Sequence')
    json.viewingHint 'individuals'
    json.canvases do
      json.array! [0] do
        json.set!('@id', manifestation_url(@manifestation))
        json.set!('@type', 'sc:Canvas')
        json.label @manifestation.attachment_file_name
        json.width 1024
        json.height 1024
        json.images do
          json.array! [0] do
            json.set!('@type', 'oa:Annotation')
            json.on manifestation_url(@manifestation)
            json.motivation 'sc:painting'
            json.resource do
              json.set!('@id', manifestation_url(@manifestation, format: :download))
              json.set!('@type', 'dctypes:Image')
              json.service do
                json.set!('@context', 'http://iiif.io/api.image/2/context.json')
                json.set!('@id', "#{ENV['ENJU_LEAF_BASE_URL']}/image-service/#{@manifestation.id}")
                json.profile 'http://iiif.io/api/image/2/level1.json'
              end
            end
          end
        end
      end
    end
  end
end

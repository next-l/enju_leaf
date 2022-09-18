class Resourcesync
  def initialize
    @base_url = if ENV['ENJU_LEAF_RESOURCESYNC_BASE_URL'].present?
                  URI.parse(ENV['ENJU_LEAF_RESOURCESYNC_BASE_URL']).to_s
                else
                  URI.parse(ENV['ENJU_LEAF_BASE_URL']).to_s
                end
  end

  def generate_capabilitylist
    capabilitylist = Resync::CapabilityList.new(
      links: [Resync::Link.new(rel: 'up', uri: @base_url)],
      resources: [
        Resync::Resource.new(uri: "#{@base_url}/resourcelist.xml", metadata: Resync::Metadata.new(capability: 'resourcelist')),
        Resync::Resource.new(uri: "#{@base_url}/changelist.xml", metadata: Resync::Metadata.new(capability: 'changelist'))
      ]
    )

    capabilitylist.save_to_xml
  end

  def generate_resourcelist_index(manifestations)
    last_updated = manifestations.order(:updated_at).first&.updated_at

    resourcelist_index = Resync::ResourceListIndex.new(
      links: [ Resync::Link.new(rel: 'up', uri: "#{@base_url}/capabilitylist.xml") ],
      metadata: Resync::Metadata.new(
        capability: 'resourcelist',
        from_time: manifestations.order(:updated_at).pick(:updated_at)
      ),
      resources: ((manifestations.count / 50000) + 1).times.map do |i|
        Resync::Resource.new(
          uri: URI.parse("#{@base_url}/resourcelist_#{i}.xml").to_s,
          modified_time: Time.zone.now
        )
      end
    )

    resourcelist_index.save_to_xml
  end

  def generate_resourcelist(manifestations)
    xml_lists = []
    last_updated = manifestations.order(:updated_at).first&.updated_at

    manifestations.find_in_batches(batch_size: 50000).with_index do |works, i|
      resourcelist = Resync::ResourceList.new(
        links: [ Resync::Link.new(rel: 'up', uri: URI.parse("#{@base_url}/capabilitylist.xml").to_s) ],
        metadata: Resync::Metadata.new(
          capability: 'resourcelist',
          from_time: last_updated
        ),
        resources: works.map{|m|
          Resync::Resource.new(
            uri: "#{@base_url}/manifestations/#{m.id}",
            modified_time: m.updated_at
          )
        }
      )

      xml_lists << resourcelist.save_to_xml
    end

    xml_lists
  end

  def generate_changelist_index(manifestations)
    last_updated = manifestations.order(:updated_at).first&.updated_at

    changelist_index = Resync::ChangeListIndex.new(
      links: [ Resync::Link.new(rel: 'up', uri: URI.parse("#{@base_url}/capabilitylist.xml").to_s) ],
      metadata: Resync::Metadata.new(
        capability: 'changelist',
        from_time: manifestations.order(:updated_at).pick(:updated_at)
      ),
      resources: ((manifestations.count / 50000) + 1).times.map do |i|
        Resync::Resource.new(
          uri: URI.parse("#{@base_url}/changelist_#{i}.xml").to_s,
          modified_time: Time.zone.now
        )
      end
    )

    changelist_index.save_to_xml
  end

  def generate_changelist(manifestations)
    xml_lists = []
    last_updated = manifestations.order(:updated_at).first&.updated_at

    manifestations.find_in_batches(batch_size: 50000).with_index do |works, i|
      changelist = Resync::ChangeList.new(
        links: [ Resync::Link.new(rel: 'up', uri: URI.parse("#{@base_url}/capabilitylist.xml").to_s) ],
        metadata: Resync::Metadata.new(
          capability: 'changelist',
          from_time: last_updated
        ),
        resources: works.map{|m|
          Resync::Resource.new(
            uri: "#{@base_url}/manifestations/#{m.id}",
            modified_time: m.updated_at,
            metadata: Resync::Metadata.new(
              change: Resync::Types::Change::UPDATED,
              # datetime: m.updated_at
            )
          )
        }
      )

      xml_lists << changelist.save_to_xml
    end

    xml_lists
  end
end

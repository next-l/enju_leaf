module OaiController
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    private
    def check_oai_params(params)
      oai = {}
      if params[:format] == 'oai'
        oai[:need_not_to_search] = nil
        oai[:errors] = []
        case params[:verb]
        when 'Identify'
          oai[:need_not_to_search] = true
        when 'ListSets'
          oai[:need_not_to_search] = true
        when 'ListMetadataFormats'
          oai[:need_not_to_search] = true
        when 'ListIdentifiers'
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "cannotDisseminateFormat"
          end
        when 'ListRecords'
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "cannotDisseminateFormat"
          end
        when 'GetRecord'
          if params[:identifier].blank?
            oai[:need_not_to_search] = true
            oai[:errors] << "badArgument"
          end
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "cannotDisseminateFormat"
          end
        else
          oai[:errors] << "badVerb"
        end
      end
      return oai
    end

    def valid_metadata_format?(format)
      if format.present?
        if ['oai_dc'].include?(format)
          true
        else
          false
        end
      else
        true
      end
    end
  end

  def get_resumption_token(token)
    resumption = Rails.cache.read(token) rescue nil
  end

  def set_resumption_token(resources, from_time, until_time, per_page = nil)
    if params[:format] == 'oai'
      if params[:resumptionToken]
        if resumption = Rails.cache.read(params[:resumptionToken]) rescue nil
          @cursor = resumption[:cursor] + per_page ||= resources.per_page
        end
      end
      @cursor ||= 0
      yml = YAML.load_file("#{RAILS_ROOT}/config/memcached.yml")
      ttl = yml["#{ENV['RAILS_ENV']}"]["ttl"] || yml["defaults"]["ttl"]
      resumption = {
        :token => "f(#{from_time.utc.iso8601.to_s}).u(#{until_time.utc.iso8601.to_s}):#{@cursor}",
        :cursor => @cursor,
        # memcachedの使用が前提
        :expired_at => ttl.seconds.from_now.utc.iso8601
      }
      @resumption = Rails.cache.fetch(resumption[:token]){resumption}
    end
  end

  def set_from_and_until(klass, from_t, until_t)
    if klass.first and klass.last
      from_t ||= klass.last.updated_at.to_s
      until_t ||= klass.first.updated_at.to_s
    else
      from_t ||= Time.zone.now.to_s
      until_t ||= Time.zone.now.to_s
    end

    times = {}
    if /^[12]\d{3}-(0?[1-9]|1[0-2])-(0?[1-9]|[12]\d|3[01])$/ =~ from_t
      times[:from] = Time.zone.parse(from_t).beginning_of_day
    else
      times[:from] = Time.zone.parse(from_t)
    end
    if /^[12]\d{3}-(0?[1-9]|1[0-2])-(0?[1-9]|[12]\d|3[01])$/ =~ until_t
      times[:until] = Time.zone.parse(until_t).beginning_of_day
    else
      times[:until] = Time.zone.parse(until_t)
    end
    times[:from] ||= Time.zone.parse(from_t)
    times[:until] ||= Time.zone.parse(until_t)
    times
  end
end

# SystemConfigurationの簡易設定
def update_system_configuration(key, value)
  Rails.cache.clear
  sc = SystemConfiguration.find_by_keyname(key)
  unless sc
    t = case value
        when String
          'String'
        when true, false
          'Boolean'
        when Fixnum
          'Numeric'
        end
    sc = SystemConfiguration.new(keyname: key, typename: t)
  end
  sc.v = value.to_s
  sc.save!
end

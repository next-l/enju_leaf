VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassette_library'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
end

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassette_library'
  c.hook_into                :fakeweb
  c.ignore_localhost         = true
  c.default_cassette_options = {
    :record => :none,
    :preserve_exact_body_bytes => true
  }
end

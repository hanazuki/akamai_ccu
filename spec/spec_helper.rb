require 'webmock/rspec'
require 'vcr'
require 'rspec/json_expectations'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'akamai_ccu'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

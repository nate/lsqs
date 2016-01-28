require 'lsqs'
require 'webmock/rspec'
include LSQS

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
  config.color = true

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.before(:each) do
    stub_request(:any, /www.example.com/).to_rack(Server)
  end
end

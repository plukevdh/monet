require 'vcr'
require 'rspec/given'
require 'timecop'
require 'pry'

require 'monet/config'
require 'monet/page_logger'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.mock_with :flexmock
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.before(:all) do
    Monet::PageLogger.reset
  end
end
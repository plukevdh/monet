require "monet/version"
require "monet/errors"
require "monet/capture_map"
require "monet/capture"
require "monet/compare"

module Monet
  class << self
    def capture(opts)
      config = Monet::Config.build_config(config)

      agent = Monet::Capture.new(config)
      agent.capture_all
    end
  end
end

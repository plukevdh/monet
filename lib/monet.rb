require "monet/version"
require 'monet/config'
require "monet/capture"
require "monet/compare"
require "monet/baseline_control"

module Monet
  class << self
    def clean(opts)
      config = load_config(opts)
      Dir.glob(File.join(config.baseline_dir, "**", "*.png")).each do |img|
        File.delete img
      end
    end

    def capture(opts)
      agent = Monet::Capture.new(load_config(opts))
      agent.capture_all
    end

    def compare(opts)
      control = Monet::BaselineControl.new(opts)
      control.run
    end

    def config(&block)
      Monet::Config.config block
    end

    def load_config(options)
      Monet::Config.build_config(options)
    end
  end
end

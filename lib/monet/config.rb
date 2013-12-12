require 'monet/capture_map'

module Monet
  class Config
    MissingBaseURL = Class.new(Exception)

    DEFAULT_OPTIONS = {
      driver: :poltergeist,
      dimensions: [1440],
      map: nil,
      base_url: nil,
      capture_dir: "./captures"
    }

    attr_accessor *DEFAULT_OPTIONS.keys

    def initialize(opts={})
      DEFAULT_OPTIONS.each do |opt, default|
        send "#{opt}=", opts[opt] || default
      end
    end

    def self.config(&block)
      cfg = new
      block.call cfg
      cfg
    end

    def base_url
      raise MissingBaseURL, "Please set the base_url in the config" unless @base_url
      @base_url
    end

    def capture_dir=(path)
      @capture_dir = File.expand_path(path)
    end

    def map(type=:explicit, &block)
      @map ||= CaptureMap.new(base_url, type)

      block.call(@map) if block_given? && type == :explicit
      @map
    end
  end
end
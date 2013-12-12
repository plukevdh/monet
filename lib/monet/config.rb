require 'monet/capture_map'
require 'yaml'

module Monet
  class Config
    include URLHelpers

    MissingBaseURL = Class.new(Exception)

    DEFAULT_OPTIONS = {
      driver: :poltergeist,
      dimensions: [1024],
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

    def self.load_config(path="./config.yaml")
      config = YAML::load(File.open(path))
      new(config[config])
    end

    def base_url=(url)
      @base_url ||= parse_uri(url) unless url.nil?
    end

    def base_url
      raise MissingBaseURL, "Please set the base_url in the config" unless @base_url
      @base_url
    end

    def capture_dir=(path)
      @capture_dir = File.expand_path(path)
    end

    def map(type=:explicit, paths=[], &block)
      @map ||= CaptureMap.new(base_url, type)

      if type == :explicit
        @map.paths = paths
        block.call(@map) if block_given?
      end

      @map
    end
  end
end
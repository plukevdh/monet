require 'monet/capture_map'
require 'yaml'

module Monet
  class Config
    include URLHelpers

    MissingBaseURL = Class.new(Exception)

    DEFAULT_OPTIONS = {
      driver: :poltergeist,
      dimensions: [1024],
      base_url: nil,
      map: nil,
      compare_type: "ColorBlend",
      capture_dir: "./captures",
      baseline_dir: "./baselines"
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

    def self.load(path="./config.yaml")
      config = YAML::load(File.open(path))
      new(config)
    end

    def self.build_config(opts)
      (opts.is_a? Monet::Config) ? opts : new(opts)
    end

    def base_url=(url)
      @base_url ||= parse_uri(url) unless url.nil?
    end

    def base_url
      raise MissingBaseURL, "Please set the base_url in the config" unless @base_url
      @base_url
    end

    def capture_dir=(path)
      @capture_dir = expand_path(path)
    end

    def baseline_dir=(path)
      @baseline_dir = expand_path(path)
    end

    def map=(paths)
      map.paths = paths unless paths.nil?
    end

    def map(type=:explicit, &block)
      @map ||= CaptureMap.new(base_url, type)

      block.call(@map) if block_given? && type == :explicit

      @map
    end

    private
    def expand_path(path)
      File.expand_path(path)
    end
  end
end
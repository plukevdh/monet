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
      baseline_dir: "./baselines",
      thumbnail_dir: "./thumbnails",
      thumbnail: false
    }

    attr_accessor *DEFAULT_OPTIONS.keys

    # configure via options
    def initialize(opts={})
      DEFAULT_OPTIONS.each do |opt, default|
        send "#{opt}=", opts[opt] || default
      end
    end

    # configure via block
    def self.config(&block)
      cfg = new
      yield cfg if block_given?

      cfg
    end

    # configure via YAML
    def self.load(path="./config.yaml")
      opts = YAML::load(File.open(path))
      new(opts)
    end

    def base_url=(url)
      @base_url = parse_uri(url) unless url.nil?
    end

    def base_url
      raise MissingBaseURL, "Please set the base_url in the config" unless @base_url
      @base_url
    end

    def site
      parse_uri(base_url).host
    end
    alias_method :host, :site
    alias_method :root_dir, :site

    def thumbnail?
      !!thumbnail
    end

    def capture_dir=(path)
      @capture_dir = expand_path(path)
    end

    def baseline_dir=(path)
      @baseline_dir = expand_path(path)
    end

    def thumbnail_dir=(path)
      @thumbnail_dir = expand_path(path)
    end

    def map=(paths)
      @map = nil
      map.paths = paths unless paths.nil?
    end

    def map(type=:explicit, &block)
      @map ||= CaptureMap.new(base_url, type)
      yield @map if block_given?

      @map
    end

    private
    def expand_path(path)
      File.expand_path(path)
    end
  end
end
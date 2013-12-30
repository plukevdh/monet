  require 'monet/url_helpers'

module Monet
  class Image
    class << self
      include URLHelpers
    end

    NoDiffFound = Class.new(Exception)

    def initialize(path, config)
      @path = File.expand_path path
      @config = config
    end

    def self.from_url(url, config, width)
      @url = url
      uri = parse_uri(url)
      path = image_path(config.capture_dir, uri, width)
      new path, config
    end

    def self.from_config(config)
      images = []
      config.map.paths.each do |path|
        config.dimensions.each do |width|
          url = "#{config.base_url}#{path}"
          images << from_url(url, config, width)
        end
      end

      images
    end

    def self.all_for_site(site, config)
      files = Dir.glob(File.join(config.baseline_dir, site, "*.png"))
      files.map do |path|
        new(path, config)
      end
    end

    def baseline?
      @path.include? @config.baseline_dir
    end

    def flagged?
      begin
        diff
        true
      rescue NoDiffFound => e
        false
      end
    end

    def width
      @width ||= File.basename(@path, ".png").split("-").last.to_i
    end

    def baseline
      File.join @config.baseline_dir, basename
    end

    def thumbnail
      File.join @config.thumbnail_dir, basename
    end

    def capture
      File.join @config.capture_dir, basename
    end

    def image_url(type_dir, public_folder)
      relative_path = Pathname.new(type_dir).relative_path_from(Pathname.new(public_folder))
      "/#{relative_path}/#{root_dir}/#{name}"
    end

    def url
      @url ||= begin
        url = @path.split("/").last
        path = url.split('|')[1..-1].join("/").gsub(/-\d+\.png/, "")

        "#{@config.base_url}/#{path}"
      end
    end

    def name
      @name ||= File.basename @path
    end

    %w(baseline capture thumbnail).each do |type|
      define_method "#{type}_url" do |public_folder|
        type_dir = @config.send "#{type}_dir"
        image_url(type_dir, public_folder)
      end
    end

    def basename
      @path.split(File::SEPARATOR)[-2..-1].join(File::SEPARATOR)
    end

    def diff
      @diff ||= baseline.gsub(".png", "-diff.png")
      raise NoDiffFound, "No diff exists for #{basename}" unless File.exists?(@diff)
      @diff
    end

    def host
      @host ||= self.class.host(@config.base_url)
    end
    alias :root_dir :host

    def self.host(url)
      parse_uri(url).host
    end

    def to_image
      ChunkyPNG::Image.from_file(@path)
    end

    private
    def self.image_path(base_dir, uri, width)
      base = host(uri)
      name = "#{base}#{uri.path}".gsub(/\//, '|')
      "#{base_dir}/#{base}/#{name}-#{width}.png"
    end
  end
end
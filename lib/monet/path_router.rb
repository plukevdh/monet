require 'monet/url_helpers'

module Monet
  class PathRouter
    include URLHelpers

    def initialize(config)
      @base_url = parse_uri(config.base_url)
      @capture_path = config.capture_dir
      @baseline_path = config.baseline_dir
    end

    def build_url(path)
      "#{@base_url}#{path}"
    end

    # takes a url, gives the image path
    def route_url(url, width="*")
      uri = parse_uri(url)
      route_url_path(uri.path, width)
    end

    # takes a url path, gives the image path
    def route_url_path(path, width="*")
      image_name(@capture_path, path, width)
    end

    def url_to_baseline(url, width)
      uri = parse_uri(url)
      url_path_to_baseline(uri.path, width)
    end

    def url_path_to_baseline(path, width)
      image_name(@baseline_path, path, width)
    end

    def capture_to_baseline(path)
      path.gsub(@capture_path, @baseline_path)
    end

    # takes a path, returns the URL used to generate the image
    def route_path(path)
      url = path.split("/").last
      path = url.split('>')[1..-1].join("/").gsub(/-\d+\.png/, "")

      "#{@base_url}/#{path}"
    end

    def host
      @base_url.host
    end

    private
    def image_name(base_dir, path, width)
      name = normalize_path(path).gsub(/\//, '>')
      "#{base_dir}/#{host}/#{name}-#{width}.png"
    end

    def normalize_path(path)
      "#{host}#{path}"
    end
  end
end
require 'monet/url_helpers'

module Monet
  class PathRouter
    include URLHelpers

    def initialize(base_url, capture_path)
      @base_url = parse_uri(base_url)
      @capture_path = capture_path
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
      image_name(path, width)
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
    def image_name(path, width)
      name = normalize_path(path).gsub(/\//, '>')
      "#{@capture_path}/#{host}/#{name}-#{width}.png"
    end

    def normalize_path(path)
      "#{host}#{path}"
    end
  end
end
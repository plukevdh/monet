require 'spidr'

module Monet
  class CaptureMap
    extend Forwardable

    class PathCollection
      attr_reader :paths, :root_url

      def initialize(root_url)
        @root_url = root_url
        @paths = []
      end

      def add(path)
        @paths << normalized_path(path)
      end

      def normalized_path(path)
        path.chomp "/"
      end
    end

    class PathSpider < PathCollection
      SKIP_EXT = %w(js css png jpg mp4 txt zip ico ogv ogg pdf gz)
      SKIP_PATHS = [/\?.*/]

      def paths
        @paths = normalize Spidr.site(@root_url, ignore_links: ignores)
      end

      def ignores
        SKIP_EXT.map {|x| Regexp.new x }.concat SKIP_PATHS
      end

      private
      def normalize(spider_results)
        spider_results.history.map &:to_s
      end
    end

    InvalidURL = Class.new(StandardError)

    attr_reader :type

    def initialize(root_url, type=:explicit, &block)
      @type = type
      @path_helper = type_mapper.new parse_uri(root_url)

      yield(@path_helper) if block_given?
    end

    def_delegators :@path_helper, :paths, :add, :root_url

    def type_mapper
      case @type
      when :explicit
        PathCollection
      when :spider
        PathSpider
      end
    end

    private
    def parse_uri(path)
      uri = URI.parse path
      raise InvalidURL, "#{path} is not a valid url" if uri.class == URI::Generic

      uri.to_s
    end
  end
end
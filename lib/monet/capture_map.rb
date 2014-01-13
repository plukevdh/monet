require 'spidr'
require 'monet/url_helpers'
require 'forwardable'

module Monet
  class CaptureMap
    extend Forwardable

    class PathCollection
      extend Forwardable

      include URLHelpers
      attr_reader :paths, :root_url

      def initialize(root_uri)
        @root_url = parse_uri(root_uri)
        @paths = []
      end

      def add(path)
        @paths << normalized_path(path)
      end

      def paths=(paths)
        @paths.concat paths.map {|p| normalized_path(p) }
      end

      def normalized_path(path)
        path.chomp "/"
      end

      def_delegators :@paths, :size, :length, :count
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

    attr_reader :type

    def initialize(root_uri, type=:explicit, &block)
      @type = type
      @path_helper = type_mapper.new root_uri

      yield(@path_helper) if block_given?
    end

    def_delegators :@path_helper, :paths, :paths=, :add, :root_url, :size, :count, :length

    def type_mapper
      case @type
      when :explicit
        PathCollection
      when :spider
        PathSpider
      end
    end
  end
end
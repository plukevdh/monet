module Monet
  class CaptureMap
    extend Forwardable

    class PathHelper
      attr_reader :paths

      def initialize
        @paths = []
      end

      def add(elements)
        normalized_paths = Array(elements).map {|path| path.chomp "/" }
        @paths.concat normalized_paths
      end
    end

    attr_reader :name
    def initialize(name, &block)
      @name = name.to_sym
      @path_helper = PathHelper.new

      yield(@path_helper) if block_given?
    end

    def_delegator :@path_helper, :paths
  end
end
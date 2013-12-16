require 'monet/path_router'
require 'monet/changeset'
require 'monet/baseless_image'
require 'fileutils'

module Monet
  class BaselineControl

    attr_reader :flags

    def initialize(config)
      @capture_dir = config.capture_dir
      @baseline_dir = config.baseline_dir

      @router = Monet::PathRouter.new(config)
      @flags = []
    end

    def compare(diff)
      return baseline(diff) if diff.is_a? Monet::BaselessImage
      return discard(diff.path) unless diff.modified?

      flags << diff.path
    end

    def captures
      Dir.glob File.join(@capture_dir, "*.png")
    end

    def discard(path)
      FileUtils.remove(path)
    end

    def baseline(diff)
      path = diff.path

      FileUtils.move(path, @baseline_dir)
      @router.capture_to_baseline(path)
    end
  end
end


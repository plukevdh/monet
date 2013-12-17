require 'monet/path_router'
require 'monet/changeset'
require 'monet/baseless_image'
require 'monet/compare'

require 'fileutils'

module Monet
  class BaselineControl

    attr_reader :flags

    def initialize(config)
      @capture_dir = config.capture_dir
      @baseline_dir = config.baseline_dir

      strategy = Monet.const_get(config.compare_type)

      @comparer = Monet::Compare.new(strategy)
      @router = Monet::PathRouter.new(config)
      @flags = []
    end

    def run
      captures.each do |capture|
        baseline_path = @router.capture_to_baseline(capture)
        compare @comparer.compare(baseline_path, capture)
      end

      @flags
    end

    def compare(diff)
      return baseline(diff) if diff.is_a? Monet::BaselessImage
      return discard(diff.path) unless diff.modified?

      puts "diff found #{diff.path}"

      @flags << diff.path
    end

    def captures
      Dir.glob File.join(site_dir(@capture_dir), "*.png")
    end

    def discard(path)
      puts "discarding #{path}"
      FileUtils.remove(path)
    end

    def baseline(diff)
      path = diff.path
      to = site_dir(@baseline_dir)

      FileUtils.mkpath to unless Dir.exists? to
      FileUtils.move(path, to)

      puts "baselining #{path}"

      @router.capture_to_baseline(path)
    end

    private
    def site_dir(base)
      File.join base, @router.root_dir
    end
  end
end
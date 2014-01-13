require 'monet/image'
require 'monet/changeset'
require 'monet/baseless_image'
require 'monet/compare'

require 'fileutils'

module Monet
  class BaselineControl

    attr_reader :flags

    def initialize(config)
      @config = config

      strategy = Monet.const_get(config.compare_type)

      @router = Monet::Router.new config
      @comparer = Monet::Compare.new(strategy)
      @flags = []
    end

    def run
      captures.each do |img|
        compare @comparer.compare(@router.baseline_dir(img.name), img.path)
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
      files = Dir.glob(File.join(@config.capture_dir, @config.site, "*.png"))
      files.map do |path|
        Monet::Image.new(path)
      end
    end

    def discard(path)
      puts "discarding #{path}"
      FileUtils.remove(path) if File.exists?(path)
    end

    def baseline(diff)
      image = diff.is_a?(String) ? Monet::Image.new(diff) : diff.image

      puts "baselining #{image.path}"
      image = rebase(image)

      # delete diff image
      discard @router.diff_dir(image.name)

      image.thumbnail!(@router.thumbnail_dir) if @config.thumbnail?
      image.path
    end

    private
    # returns a new image for the moved image
    def rebase(image)
      new_path = @router.baseline_dir(image.name)

      create_path_for_file(new_path)
      FileUtils.move(image.path, new_path)

      Monet::Image.new(new_path)
    end

    def create_path_for_file(file)
      path = File.dirname(file)
      FileUtils.mkpath path unless Dir.exists? path
    end
  end
end
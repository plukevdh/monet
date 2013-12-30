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

      @comparer = Monet::Compare.new(strategy)
      @flags = []
    end

    def run
      captures.each do |img|
        compare @comparer.compare(img.baseline, img.capture)
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
      files = Dir.glob(File.join(@config.capture_dir, Monet::Image.host, "*.png"))
      files.map do |path|
        Monet::Image.new(path, @config)
      end
    end

    def discard(path)
      puts "discarding #{path}"
      FileUtils.remove(path)
    end

    def baseline(diff)
      image = diff.image, @config

      FileUtils.mkpath image.root_dir unless Dir.exists? image.root_dir
      FileUtils.move(image.capture, image.baseline)

      puts "baselining #{image.capture}"

      image.baseline
    end
  end
end
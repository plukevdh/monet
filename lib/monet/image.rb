require 'chunky_png'
require 'monet/config'
require 'monet/url_helpers'

module Monet
  class Image
    include URLHelpers

    def initialize(path)
      @path = File.expand_path path
    end

    def is_diff?
      name.include? "-diff"
    end

    def width
      @width ||= File.basename(@path, ".png").split("-").last.to_i
    end

    def name
      @name ||= File.basename @path
    end

    def basename
      @path.split(File::SEPARATOR)[-2..-1].join(File::SEPARATOR)
    end

    def to_image
      ChunkyPNG::Image.from_file(@path)
    end

    def thumbnail!(save_to=nil)
      img = to_image
      short_edge = [img.width, img.height].min

      cropped = img.crop(0, 0, short_edge, short_edge)
      resized = cropped.resize(200, 200)

      if save_to.nil?
        save_to = @path.gsub(".png", "-thumb.png")
      else
        save_to = File.join save_to, File.basename(@path)
      end

      resized.save save_to
      save_to
    end
  end
end
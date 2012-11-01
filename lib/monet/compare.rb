require 'oily_png'
require 'monet/diff_strategy'

module Monet
  class Compare
    extend Forwardable

    class Changeset
      def initialize(pixel_array)
        @changed_pixels = pixel_array
      end

      def modified?
        @changed_pixels.length > 0
      end
    end

    def intialize
      @changeset = Changeset.new
    end

    def compare(base_image, new_image)
      base_png = ChunkyPNG::Image.from_file(base_image)
      new_png = ChunkyPNG::Image.from_file(new_image)

      diff_stats = []

      # TODO: make configurable
      diff_strategy = ColorBlend.new(base_png, new_png)

      base_png.height.times do |y|
        base_png.row(y).each_with_index do |pixel, x|
          diff_strategy.calculate_for_pixel(pixel, x, y)
        end
      end

      changeset = Changeset.new(diff_strategy.score)
      diff_strategy.save(diff_filename(base_image)) if changeset.modified?

      changeset
    end

    private

    def diff_filename(base_filename)
      base_filename[0..-5] << "-diff.png"
    end
  end
end
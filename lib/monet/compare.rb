require 'oily_png'
require 'monet/diff_strategy'

module Monet
  class Compare
    extend Forwardable

    class Changeset
      def initialize(base_image, pixel_array)
        @base_image = base_image
        @changed_pixels = pixel_array
      end

      def modified?
        pixels_changed > 0
      end

      def pixels_changed
        @changed_pixels.count
      end

      def percentage_changed
        ((pixels_changed.to_f / @base_image.area.to_f) * 100).round(2)
      end
    end

    def initialize(strategy=ColorBlend)
      @strategy_class = strategy
    end

    def compare(base_image, new_image)
      base_png = ChunkyPNG::Image.from_file(base_image)
      new_png = ChunkyPNG::Image.from_file(new_image)

      diff_stats = []

      # TODO: make configurable
      diff_strategy = @strategy_class.new(base_png, new_png)

      base_png.height.times do |y|
        base_png.row(y).each_with_index do |pixel, x|
          diff_strategy.calculate_for_pixel(pixel, x, y)
        end
      end

      changeset = Changeset.new(base_png, diff_strategy.score)
      diff_strategy.save(diff_filename(base_image)) if changeset.modified?

      changeset
    end

    private

    def diff_filename(base_filename)
      base_filename[0..-5] << "-diff.png"
    end
  end
end
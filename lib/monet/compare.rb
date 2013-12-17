require 'oily_png'
require 'monet/diff_strategy'
require 'monet/changeset'
require 'monet/baseless_image'

module Monet
  class Compare
    extend Forwardable

    def initialize(strategy=ColorBlend)
      @strategy_class = strategy
    end

    def compare(base_image, new_image)
      puts "comparing #{base_image} with #{new_image}"
      begin
        new_png = ChunkyPNG::Image.from_file(new_image)
        base_png = ChunkyPNG::Image.from_file(base_image)

        diff_stats = []

        diff_strategy = @strategy_class.new(base_png, new_png)

        base_png.height.times do |y|
          base_png.row(y).each_with_index do |pixel, x|
            diff_strategy.calculate_for_pixel(pixel, x, y)
          end
        end

        changeset = Changeset.new(base_png, diff_strategy.score, new_image)
        diff_strategy.save(diff_filename(base_image)) if changeset.modified?

        changeset
      rescue Errno::ENOENT => e
        return BaselessImage.new(new_image)
      end
    end

    private

    def diff_filename(base_filename)
      base_filename[0..-5] << "-diff.png"
    end
  end
end
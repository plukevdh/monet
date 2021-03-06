require 'monet/errors'

module Monet
  class DiffStrategy
    include ChunkyPNG::Color

    attr_reader :score

    def initialize(base_image, diff_image)
      @base_image = base_image
      @diff_image = diff_image
      @score = []

      raise Errors::DifferentDimensions unless dimensions_match?
    end

    def calculate_for_pixel(pixel, x, y)
      @score << [x,y] unless pixel == @diff_image[x,y]
    end

    def save(filename)
      @output.save(filename)
    end

    private
    def dimensions_match?
      @base_image.width == @diff_image.width &&
      @base_image.height == @diff_image.height
    end

    private
    def for_color(color, *params)
      send color, *params
    end
  end

  class Grayscale < DiffStrategy
    def initialize(base_image, diff_image)
      super
      @output = ChunkyPNG::Image.new(base_image.width, base_image.height, WHITE)
    end

    def calculate_for_pixel(pixel, x, y)
      return if pixel == @diff_image[x,y]

      rgb_colors = %w(r g b).map do |color|
        for_color(color, @diff_image[x,y]) - for_color(color, pixel)
      end

      score = Math.sqrt(rgb_colors.reduce(0) {|memo, diff| memo += (diff ** 2) } ) / Math.sqrt(MAX ** 2 * 3)

      @output[x,y] = grayscale(MAX - (score * MAX).round)
      super
    end
  end

  class ColorBlend < DiffStrategy
    def initialize(base_image, diff_image)
      super
      @output = ChunkyPNG::Image.new(base_image.width, base_image.height, BLACK)
    end

    def calculate_for_pixel(pixel, x, y)
      rgb_colors = %w(r g b).map do |color|
        for_color(color, pixel) + for_color(color, @diff_image[x,y]) - 2 * [for_color(color, pixel), for_color(color, @diff_image[x,y])].min
      end

      @output[x,y] = rgb(*rgb_colors)
      super
    end
  end

  class Highlight < DiffStrategy
    ALPHA_COMPONENT = 30

    def initialize(base_image, diff_image)
      super
      @output = ChunkyPNG::Image.new(base_image.width, base_image.height, WHITE)
    end

    def colors(pixel)
      rgb_colors = %w(r g b).map {|color| for_color(color, pixel)}
    end

    def calculate_for_pixel(pixel, x, y)
      if pixel == @diff_image[x,y]
        @output[x,y] = rgba(*colors(pixel), ALPHA_COMPONENT)
      else
        @output[x,y] = html_color("blue")
      end

      super
    end
  end
end
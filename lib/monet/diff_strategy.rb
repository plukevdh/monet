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
  end

  class Grayscale < DiffStrategy
    def initialize(base_image, diff_image)
      super
      @output = ChunkyPNG::Image.new(base_image.width, base_image.height, WHITE)
    end

    def calculate_for_pixel(pixel, x, y)
      return if pixel == @diff_image[x,y]

      score = Math.sqrt(
        (r(@diff_image[x,y]) - r(pixel)) ** 2 +
        (g(@diff_image[x,y]) - g(pixel)) ** 2 +
        (b(@diff_image[x,y]) - b(pixel)) ** 2
      ) / Math.sqrt(MAX ** 2 * 3)

      @output[x,y] = grayscale(MAX - (score * MAX).round)
      super
    end
  end

  class ColorBlend < DiffStrategy
    def initialize(base_image, diff_image)
      super
      @output = ChunkyPNG::Image.new(base_image.width, diff_image.width, BLACK)
    end

    def calculate_for_pixel(pixel, x, y)
      rgb_colors = %w(r g b).map do |color|
        for_color(color, pixel) + for_color(color, @diff_image[x,y]) - 2 * [for_color(color, pixel), for_color(color, @diff_image[x,y])].min
      end

      @output[x,y] = rgb(*rgb_colors)
      super
    end

    private
    def for_color(color, *params)
      send color, *params
    end
  end
end
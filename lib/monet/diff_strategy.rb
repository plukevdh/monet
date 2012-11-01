module Monet
  class DiffStrategy
    include ChunkyPNG::Color

    attr_reader :score

    def initialize(base_image, diff_image)
      @diff_image = diff_image
      @base_image = base_image
      @score = []
    end

    def calculate_for_pixel(pixel, x, y)
      @score << [x,y] unless pixel == @diff_image[x,y]
    end

    def save(filename)
      @output.save(filename)
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
      @output[x,y] = rgb(
        r(pixel) + r(@diff_image[x,y]) - 2 * [r(pixel), r(@diff_image[x,y])].min,
        g(pixel) + g(@diff_image[x,y]) - 2 * [g(pixel), g(@diff_image[x,y])].min,
        b(pixel) + b(@diff_image[x,y]) - 2 * [b(pixel), b(@diff_image[x,y])].min
      )
      super
    end
  end
end
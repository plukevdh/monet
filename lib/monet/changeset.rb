module Monet
  class Changeset
    attr_reader :path

    def initialize(base_image, pixel_array, path)
      @base_image = base_image
      @changed_pixels = pixel_array
      @path = path
    end

    def image
      Monet::Image.new @path
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
end
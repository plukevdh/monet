require 'fileutils'

require "capybara"
require 'capybara/poltergeist'
require "capybara/dsl"

require 'monet/config'
require 'monet/image'

module Monet
  class Capture
    include Capybara::DSL

    MAX_HEIGHT = 10000

    def initialize(config)
      @config = Monet::Config.build_config(config)

      Capybara.default_driver = @config.driver
    end

    def capture_all
      images = Image.from_config(@config)
      images.each do |image|
        capture(image)
      end

      images
    end

    def capture(image_or_path, width=nil)
      if image_or_path.is_a? String
        raise ArgumentError, "Width is required if you pass an image path rather than an image object" if width.nil?
        image = Monet::Image.from_url("#{@config.base_url}#{image_or_path}".chomp("/"), @config, width)
      else
        image = image_or_path
      end

      visit image.url unless current_url == image.url

      file_path = image.capture

      page.driver.resize(image.width, MAX_HEIGHT)
      page.driver.render(file_path, full: true)

      thumbnail(image) if @config.thumbnail?
    end

    def thumbnail(image)
      img = ChunkyPNG::Image.from_file(image.capture)
      short_edge = [img.width, img.height].min
      save_path = image.thumbnail
      save_dir = File.dirname save_path

      cropped = img.crop(0, 0, short_edge, short_edge)
      resized = cropped.resize(200, 200)

      FileUtils.mkdir_p save_dir unless Dir.exists? save_dir

      resized.save save_path
    end
  end
end
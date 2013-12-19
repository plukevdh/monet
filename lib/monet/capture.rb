require 'fileutils'

require "capybara"
require 'capybara/poltergeist'
require "capybara/dsl"

require 'monet/config'
require 'monet/path_router'

module Monet
  class Capture
    include Capybara::DSL

    MAX_HEIGHT = 10000

    def initialize(config)
      @config = Monet::Config.build_config(config)
      @router = Monet::PathRouter.new(@config)

      Capybara.default_driver = @config.driver
    end

    def capture_all
      @config.map.paths.each do |path|
        capture(path)
      end
    end

    def capture(path)
      visit @router.build_url(path)

      @config.dimensions.each do |width|
        file_path = @router.route_url_path(path, width)

        page.driver.resize(width, MAX_HEIGHT)
        page.driver.render(file_path, full: true)

        thumbnail(file_path) if @config.thumbnail?
      end
    end

    def thumbnail(path)
      img = ChunkyPNG::Image.from_file(path)
      short_edge = [img.width, img.height].min
      save_path = @router.capture_to_thumbnail(path)
      save_dir = File.dirname save_path

      puts save_path

      cropped = img.crop(0, 0, short_edge, short_edge)
      resized = cropped.resize(200, 200)

      FileUtils.mkdir_p save_dir unless Dir.exists? save_dir

      resized.save save_path
    end
  end
end
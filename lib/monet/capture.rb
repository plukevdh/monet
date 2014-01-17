require 'fileutils'

require "capybara"
require 'capybara/poltergeist'
require "capybara/dsl"

require 'monet/router'
require 'monet/image'
require 'monet/error_image'
require 'monet/page_logger'

module Monet
  class Capture
    include Capybara::DSL
    include Monet::PageLogger::Helpers

    MAX_HEIGHT = 10000

    def initialize(config)
      @config = config
      @router = Monet::Router.new config

      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, {js_errors: false})
      end
      Capybara.default_driver = @config.driver
    end

    def capture_all
      images = []
      @router.capture_routes.map do |url, paths|
        # visit_once url

        paths.each do |path|
          images << capture(url, path)
        end
      end

      images
    end

    def capture(url, image_or_save_path)
      image = (image_or_save_path.is_a? String) ? Monet::Image.new(image_or_save_path) : image_or_save_path

      visit_once url

      page.driver.resize(image.width, MAX_HEIGHT)
      page.driver.render(image.path, full: true)

      image.thumbnail!(@router.thumbnail_dir) if @config.thumbnail?

      log_page(url, page.status_code)
      return ErrorImage.new(image.path, page.status_code) if failed?(url)

      image
    end

    private
    def visit_once(url)
      visit url unless current_url == url
    end
  end
end